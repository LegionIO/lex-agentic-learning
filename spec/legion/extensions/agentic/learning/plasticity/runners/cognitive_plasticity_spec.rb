# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::Plasticity::Runners::CognitivePlasticity do
  let(:client) { Legion::Extensions::Agentic::Learning::Plasticity::Client.new }

  describe '#create_pathway' do
    it 'returns success with pathway hash' do
      result = client.create_pathway(label: 'test')
      expect(result[:success]).to be true
      expect(result[:pathway]).to include(:id, :label, :strength, :plasticity)
    end
  end

  describe '#strengthen_pathway' do
    it 'increases pathway strength' do
      p = client.create_pathway(label: 'test')
      pid = p[:pathway][:id]
      result = client.strengthen_pathway(pathway_id: pid)
      expect(result[:success]).to be true
      expect(result[:pathway][:strength]).to be > 0.3
    end

    it 'returns failure for unknown id' do
      result = client.strengthen_pathway(pathway_id: 'fake')
      expect(result[:success]).to be false
    end
  end

  describe '#weaken_pathway' do
    it 'decreases pathway strength' do
      p = client.create_pathway(label: 'test')
      pid = p[:pathway][:id]
      result = client.weaken_pathway(pathway_id: pid)
      expect(result[:success]).to be true
      expect(result[:pathway][:strength]).to be < 0.3
    end
  end

  describe '#rejuvenate_pathway' do
    it 'increases pathway plasticity' do
      p = client.create_pathway(label: 'test')
      pid = p[:pathway][:id]
      client.strengthen_pathway(pathway_id: pid)
      result = client.rejuvenate_pathway(pathway_id: pid, amount: 0.2)
      expect(result[:success]).to be true
    end
  end

  describe '#enter_critical_period / #exit_critical_period' do
    it 'toggles critical period' do
      result = client.enter_critical_period
      expect(result[:critical_period]).to be true
      result = client.exit_critical_period
      expect(result[:critical_period]).to be false
    end
  end

  describe '#prune_weak_pathways' do
    it 'returns pruned count' do
      client.create_pathway(label: 'weak', initial_strength: 0.05)
      result = client.prune_weak_pathways
      expect(result[:success]).to be true
      expect(result[:pruned_count]).to eq(1)
    end
  end

  describe '#strongest_pathways' do
    it 'returns pathways array' do
      client.create_pathway(label: 'a')
      result = client.strongest_pathways
      expect(result[:success]).to be true
      expect(result[:pathways]).to be_a(Array)
    end
  end

  describe '#plasticity_report' do
    it 'returns a full report' do
      result = client.plasticity_report
      expect(result[:success]).to be true
      expect(result[:report]).to include(:total_pathways, :average_plasticity)
    end
  end
end
