# frozen_string_literal: true

require 'legion/extensions/agentic/learning/outcome_listener/client'

RSpec.describe Legion::Extensions::Agentic::Learning::OutcomeListener::Client do
  before { described_class.reset! }

  it 'responds to process_outcome' do
    client = described_class.new
    expect(client).to respond_to(:process_outcome)
  end

  describe '.meta_client' do
    it 'returns a MetaLearning::Client' do
      expect(described_class.meta_client).to be_a(
        Legion::Extensions::Agentic::Learning::MetaLearning::Client
      )
    end

    it 'returns the same instance on repeated calls' do
      expect(described_class.meta_client).to equal(described_class.meta_client)
    end
  end

  describe '.scaffolding_client' do
    it 'returns a Scaffolding::Client' do
      expect(described_class.scaffolding_client).to be_a(
        Legion::Extensions::Agentic::Learning::Scaffolding::Client
      )
    end

    it 'returns the same instance on repeated calls' do
      expect(described_class.scaffolding_client).to equal(described_class.scaffolding_client)
    end
  end

  describe '.learning_rate_client' do
    it 'returns a LearningRate::Client' do
      expect(described_class.learning_rate_client).to be_a(
        Legion::Extensions::Agentic::Learning::LearningRate::Client
      )
    end

    it 'returns the same instance on repeated calls' do
      expect(described_class.learning_rate_client).to equal(described_class.learning_rate_client)
    end
  end

  describe '.domain_map' do
    it 'returns an empty hash initially' do
      expect(described_class.domain_map).to eq({})
    end

    it 'persists entries across calls' do
      described_class.domain_map['test'] = 'id-123'
      expect(described_class.domain_map['test']).to eq('id-123')
    end
  end

  describe '.reset!' do
    it 'clears all shared state' do
      described_class.meta_client
      described_class.scaffolding_client
      described_class.learning_rate_client
      described_class.domain_map['test'] = 'id'

      described_class.reset!

      expect(described_class.domain_map).to eq({})
      expect(described_class.instance_variable_get(:@meta_client)).to be_nil
      expect(described_class.instance_variable_get(:@scaffolding_client)).to be_nil
      expect(described_class.instance_variable_get(:@learning_rate_client)).to be_nil
    end
  end
end
