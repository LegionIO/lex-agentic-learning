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

    it 'handles empty payload gracefully' do
      result = client.process_outcome({})
      expect(result[:success]).to be true
      expect(result[:domain]).to eq('unknown')
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
