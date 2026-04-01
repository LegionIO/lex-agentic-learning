# frozen_string_literal: true

require 'legion/extensions/agentic/learning/outcome_listener/helpers/constants'
require 'legion/extensions/agentic/learning/outcome_listener/helpers/domain_extractor'

RSpec.describe Legion::Extensions::Agentic::Learning::OutcomeListener::Helpers::DomainExtractor do
  describe '.extract' do
    it 'extracts domain from standard runner class' do
      expect(described_class.extract('Legion::Extensions::Http::Runners::Get')).to eq('http')
    end

    it 'extracts domain from agentic runner class' do
      expect(described_class.extract('Legion::Extensions::Agentic::Learning::MetaLearning::Runners::MetaLearning'))
        .to eq('learning')
    end

    it 'handles consul extension' do
      expect(described_class.extract('Legion::Extensions::Consul::Runners::Kv')).to eq('consul')
    end

    it 'handles camel case domains' do
      expect(described_class.extract('Legion::Extensions::SwarmGithub::Runners::Issue')).to eq('swarm_github')
    end

    it 'returns unknown for nil input' do
      expect(described_class.extract(nil)).to eq('unknown')
    end

    it 'returns unknown for empty string' do
      expect(described_class.extract('')).to eq('unknown')
    end

    it 'falls back to second-to-last segment for non-standard format' do
      expect(described_class.extract('Custom::Runner::DoWork')).to eq('runner')
    end

    it 'handles single segment' do
      expect(described_class.extract('Worker')).to eq('worker')
    end
  end

  describe '.snake_case' do
    it 'converts CamelCase to snake_case' do
      expect(described_class.snake_case('SwarmGithub')).to eq('swarm_github')
    end

    it 'converts simple word' do
      expect(described_class.snake_case('Http')).to eq('http')
    end

    it 'handles consecutive capitals' do
      expect(described_class.snake_case('LLMGateway')).to eq('llm_gateway')
    end
  end
end
