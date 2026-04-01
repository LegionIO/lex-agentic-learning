# frozen_string_literal: true

require 'legion/extensions/agentic/learning/outcome_listener/helpers/constants'
require 'legion/extensions/agentic/learning/outcome_listener/helpers/lesson_builder'

RSpec.describe Legion::Extensions::Agentic::Learning::OutcomeListener::Helpers::LessonBuilder do
  describe '.build' do
    let(:success_lesson) do
      described_class.build(
        runner_class: 'Legion::Extensions::Http::Runners::Get',
        function:     'fetch',
        status:       'task.completed',
        domain:       'http',
        success:      true,
        source_agent: 'agent-1'
      )
    end

    let(:failure_lesson) do
      described_class.build(
        runner_class: 'Legion::Extensions::Consul::Runners::Kv',
        function:     'put',
        status:       'task.failed',
        domain:       'consul',
        success:      false,
        source_agent: 'agent-2'
      )
    end

    it 'builds a success lesson with correct outcome' do
      expect(success_lesson[:outcome]).to eq(:success)
    end

    it 'builds a failure lesson with correct outcome' do
      expect(failure_lesson[:outcome]).to eq(:failure)
    end

    it 'includes situation with runner class and function' do
      expect(success_lesson[:situation]).to eq('Legion::Extensions::Http::Runners::Get#fetch')
    end

    it 'includes domain' do
      expect(success_lesson[:domain]).to eq('http')
    end

    it 'assigns higher confidence to successes' do
      expect(success_lesson[:confidence]).to be > failure_lesson[:confidence]
    end

    it 'includes source_agent' do
      expect(success_lesson[:source_agent]).to eq('agent-1')
    end

    it 'includes recorded_at timestamp' do
      expect(success_lesson[:recorded_at]).to be_a(Time)
    end

    it 'builds lesson text for success' do
      expect(success_lesson[:lesson]).to include('completed successfully')
    end

    it 'builds lesson text for failure' do
      expect(failure_lesson[:lesson]).to include('failed')
    end
  end

  describe '.build_situation' do
    it 'combines runner_class and function' do
      result = described_class.build_situation('MyRunner', 'do_work')
      expect(result).to eq('MyRunner#do_work')
    end

    it 'omits function when nil' do
      result = described_class.build_situation('MyRunner', nil)
      expect(result).to eq('MyRunner')
    end
  end
end
