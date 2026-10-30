# frozen_string_literal: true

require 'legion/extensions/agentic/learning/outcome_listener/client'

RSpec.describe Legion::Extensions::Agentic::Learning::OutcomeListener::Runners::OutcomeListener do
  let(:client) { Legion::Extensions::Agentic::Learning::OutcomeListener::Client.new }

  before { Legion::Extensions::Agentic::Learning::OutcomeListener::Client.reset! }

  let(:completed_payload) do
    {
      runner_class: 'Legion::Extensions::Http::Runners::Get',
      function:     'fetch',
      status:       'task.completed',
      source_agent: 'agent-1'
    }
  end

  let(:failed_payload) do
    {
      runner_class: 'Legion::Extensions::Consul::Runners::Kv',
      function:     'put',
      status:       'task.failed',
      source_agent: 'agent-2'
    }
  end

  describe '#process_outcome' do
    it 'returns success hash for completed task' do
      result = client.process_outcome(completed_payload)
      expect(result[:success]).to be true
      expect(result[:domain]).to eq('http')
      expect(result[:outcome]).to be true
    end

    it 'returns success hash for failed task' do
      result = client.process_outcome(failed_payload)
      expect(result[:success]).to be true
      expect(result[:domain]).to eq('consul')
      expect(result[:outcome]).to be false
    end

    it 'updates meta_learning model on completion' do
      result = client.process_outcome(completed_payload)
      episode = result[:updates][:meta_learning]
      expect(episode[:success]).to be true
      expect(episode[:domain_name]).to eq('http')
    end

    it 'updates meta_learning model on failure' do
      result = client.process_outcome(failed_payload)
      episode = result[:updates][:meta_learning]
      expect(episode[:success]).to be false
    end

    it 'updates learning_rate model' do
      result = client.process_outcome(completed_payload)
      lr = result[:updates][:learning_rate]
      expect(lr[:success]).to be true
      expect(lr[:domain]).to eq(:http)
    end

    it 'skips scaffolding when no scaffold exists for domain' do
      result = client.process_outcome(completed_payload)
      scaffolding = result[:updates][:scaffolding]
      expect(scaffolding[:skipped]).to be true
      expect(scaffolding[:reason]).to eq(:no_scaffold)
    end

    it 'updates scaffolding when scaffold exists for domain' do
      sc = Legion::Extensions::Agentic::Learning::OutcomeListener::Client.scaffolding_client
      sc.create_scaffold(skill_name: 'http_requests', domain: 'http')
      result = client.process_outcome(completed_payload)
      scaffolding = result[:updates][:scaffolding]
      expect(scaffolding[:success]).to be true
    end

    it 'uses payload complexity for scaffolding difficulty' do
      sc = Legion::Extensions::Agentic::Learning::OutcomeListener::Client.scaffolding_client
      scaffold_result = sc.create_scaffold(skill_name: 'consul_kv', domain: 'consul')
      original_competence = scaffold_result[:scaffold][:competence]

      client.process_outcome(failed_payload.merge(complexity: 0.9))
      scaffolding_client = Legion::Extensions::Agentic::Learning::OutcomeListener::Client.scaffolding_client
      scaffold = scaffolding_client.engine.by_domain(domain: 'consul').first
      expect(scaffold.competence).to be < original_competence
    end

    it 'creates domain in meta_learning on first encounter' do
      client.process_outcome(completed_payload)
      meta = Legion::Extensions::Agentic::Learning::OutcomeListener::Client.meta_client
      stats = meta.meta_learning_stats
      expect(stats[:domain_count]).to eq(1)
    end

    it 'reuses existing domain on subsequent outcomes' do
      client.process_outcome(completed_payload)
      client.process_outcome(completed_payload)
      meta = Legion::Extensions::Agentic::Learning::OutcomeListener::Client.meta_client
      stats = meta.meta_learning_stats
      expect(stats[:domain_count]).to eq(1)
    end

    it 'accumulates proficiency across multiple successes' do
      3.times { client.process_outcome(completed_payload) }
      meta = Legion::Extensions::Agentic::Learning::OutcomeListener::Client.meta_client
      domain_id = Legion::Extensions::Agentic::Learning::OutcomeListener::Client.domain_map['http']
      episodes = meta.send(:engine).domains[domain_id]
      expect(episodes.proficiency).to be > 0.0
    end

    it 'ignores missing outcomes without creating learning state' do
      result = client.process_outcome({})
      expect(result).to include(success: false, skipped: true, outcome: nil)
      expect(Legion::Extensions::Agentic::Learning::OutcomeListener::Client.meta_client.meta_learning_stats[:episode_count]).to eq(0)
    end

    it 'consumes keyword-dispatched technical failures from the current runner' do
      result = client.process_outcome(**failed_payload, status: 'task.exception')
      expect(result).to include(success: true, outcome: false, evidence: :technical_execution)
      expect(result[:updates][:meta_learning]).to include(domain_name: 'consul', success: false)
    end

    it 'ignores nonterminal and unrecognized statuses without changing existing learning' do
      client.process_outcome(completed_payload)
      owner = Legion::Extensions::Agentic::Learning::OutcomeListener::Client
      before = owner.meta_client.learning_domain_ranking

      [nil, 'task.queued', 'transformer.succeeded', 'unexpected'].each do |status|
        result = client.process_outcome(**completed_payload, status: status)
        expect(result).to include(success: false, skipped: true, reason: :unrecognized_status, outcome: nil)
      end

      expect(owner.meta_client.learning_domain_ranking).to eq(before)
      expect(owner.meta_client.meta_learning_stats[:episode_count]).to eq(1)
    end

    it 'does not attribute context-free transport status updates to an unknown domain' do
      result = client.process_outcome(task_id: 42, status: 'task.completed')
      expect(result).to include(success: false, reason: :missing_task_context)
      expect(Legion::Extensions::Agentic::Learning::OutcomeListener::Client.meta_client.meta_learning_stats[:domain_count]).to eq(0)
    end

    it 'does not reinforce a redelivered identified outcome twice across clients' do
      payload = completed_payload.merge(task_id: 42, message_id: 'delivery-1')
      client.process_outcome(**payload)
      other = Legion::Extensions::Agentic::Learning::OutcomeListener::Client.new
      result = other.process_outcome(**payload)
      expect(result).to include(skipped: true, reason: :duplicate_outcome)
      expect(Legion::Extensions::Agentic::Learning::OutcomeListener::Client.meta_client.meta_learning_stats[:episode_count]).to eq(1)
    end

    it 'reinforces concurrent redeliveries only once per shared state lifecycle' do
      owner = Legion::Extensions::Agentic::Learning::OutcomeListener::Client
      payload = completed_payload.merge(message_id: 'concurrent-delivery')

      2.times do
        ready = Queue.new
        start = Queue.new
        workers = Array.new(8) do
          Thread.new do
            listener = owner.new
            ready << true
            start.pop
            listener.process_outcome(**payload)
          end
        end
        workers.size.times { ready.pop }
        workers.size.times { start << true }
        results = workers.map(&:value)

        expect(results.count { |result| result[:reason] == :duplicate_outcome }).to eq(7)
        expect(results).to all(include(success: true, outcome: true))
        expect(owner.meta_client.meta_learning_stats[:episode_count]).to eq(1)
        owner.reset!
      end
    end

    it 'keeps different agents and a later terminal status distinct' do
      payload = completed_payload.merge(task_id: 42, message_id: 'delivery-1')
      client.process_outcome(**payload)
      client.process_outcome(**payload, source_agent: 'agent-2')
      client.process_outcome(**payload, status: 'task.exception', message_id: 'delivery-2')
      owner = Legion::Extensions::Agentic::Learning::OutcomeListener::Client
      domain = owner.meta_client.learning_domain_ranking[:ranking].first
      expect(domain).to include(successes: 2, failures: 1)
    end

    it 'does not treat repeated task IDs as delivery identities' do
      2.times { client.process_outcome(**completed_payload, task_id: 42) }
      owner = Legion::Extensions::Agentic::Learning::OutcomeListener::Client
      expect(owner.meta_client.meta_learning_stats[:episode_count]).to eq(2)
    end

    it 'updates the same scaffold decision when invoked as a framework runner module' do
      owner = Legion::Extensions::Agentic::Learning::OutcomeListener::Client
      scaffold = owner.scaffolding_client.create_scaffold(skill_name: 'http_requests', domain: 'http')
      id = scaffold[:scaffold][:id]
      before = owner.scaffolding_client.recommend_scaffolded_task(scaffold_id: id)
      runner = Module.new
      runner.extend(described_class)
      result = runner.process_outcome(**completed_payload)

      expect(result[:success]).to be true
      after = owner.scaffolding_client.recommend_scaffolded_task(scaffold_id: id)
      expect(after[:recommendation][:difficulty]).to be > before[:recommendation][:difficulty]
      expect(owner.meta_client.meta_learning_stats[:episode_count]).to eq(1)
    end

    it 'fails closed when the lesson publication setting cannot be read' do
      allow(Legion::Settings).to receive(:dig).with(:agentic, :learning, :write_to_apollo).and_raise(IOError, 'unavailable')
      apollo = Module.new
      stub_const('Legion::Apollo', apollo)
      expect(apollo).not_to receive(:ingest)

      expect(client.process_outcome(**completed_payload)[:success]).to be true
    end
  end

  describe '#write_apollo_lesson' do
    let(:lesson) do
      { runner_class: 'Http::Get', function: 'fetch', status: 'task.completed',
        domain: 'http', success: true, confidence: 0.8 }
    end

    before do
      mock_apollo = Module.new do
        def self.ingest(**)
          { success: true }
        end
      end
      stub_const('Legion::Apollo', mock_apollo)
    end

    it 'passes access_scope: private to Legion::Apollo.ingest' do
      allow(Legion::Apollo).to receive(:ingest).and_return({ success: true })
      client.send(:write_apollo_lesson, lesson, 'agent-1')
      expect(Legion::Apollo).to have_received(:ingest).with(
        hash_including(access_scope: 'private')
      )
    end

    it 'includes source_agent in the ingest call' do
      allow(Legion::Apollo).to receive(:ingest).and_return({ success: true })
      client.send(:write_apollo_lesson, lesson, 'agent-99')
      expect(Legion::Apollo).to have_received(:ingest).with(
        hash_including(source_agent: 'agent-99')
      )
    end

    it 'tags the entry with task_outcome and domain' do
      allow(Legion::Apollo).to receive(:ingest).and_return({ success: true })
      client.send(:write_apollo_lesson, lesson, 'agent-1')
      expect(Legion::Apollo).to have_received(:ingest).with(
        hash_including(tags: array_including('task_outcome', 'http'))
      )
    end

    it 'is a no-op when Legion::Apollo is not defined' do
      hide_const('Legion::Apollo')
      expect { client.send(:write_apollo_lesson, lesson, 'agent-1') }.not_to raise_error
    end

    it 'does not inject process identity as the owner' do
      stub_const('Legion::Identity::Process', Module.new do
        extend self

        define_method(:identity_hash) do
          { canonical_name: 'daemon', db_principal_id: 999, db_identity_id: 888 }
        end
      end)
      allow(Legion::Apollo).to receive(:ingest).and_return({ success: true })
      client.send(:write_apollo_lesson, lesson, 'agent-1')
      expect(Legion::Apollo).to have_received(:ingest).with(
        hash_including(identity_principal_id: nil)
      )
    end
  end
end
