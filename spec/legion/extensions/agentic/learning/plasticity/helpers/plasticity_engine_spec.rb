# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::Plasticity::Helpers::PlasticityEngine do
  subject(:engine) { described_class.new }

  let(:pathway) { engine.create_pathway(label: 'test') }

  describe '#create_pathway' do
    it 'returns a NeuralPathway' do
      expect(pathway).to be_a(Legion::Extensions::Agentic::Learning::Plasticity::Helpers::NeuralPathway)
    end

    it 'stores the pathway' do
      pathway
      expect(engine.to_h[:total_pathways]).to eq(1)
    end
  end

  describe '#strengthen_pathway' do
    it 'increases pathway strength' do
      original = pathway.strength
      engine.strengthen_pathway(pathway_id: pathway.id)
      expect(pathway.strength).to be > original
    end

    it 'returns nil for unknown id' do
      expect(engine.strengthen_pathway(pathway_id: 'fake')).to be_nil
    end
  end

  describe '#weaken_pathway' do
    it 'decreases pathway strength' do
      original = pathway.strength
      engine.weaken_pathway(pathway_id: pathway.id)
      expect(pathway.strength).to be < original
    end
  end

  describe '#rejuvenate_pathway' do
    it 'increases pathway plasticity' do
      engine.strengthen_pathway(pathway_id: pathway.id)
      reduced = pathway.plasticity
      engine.rejuvenate_pathway(pathway_id: pathway.id, amount: 0.2)
      expect(pathway.plasticity).to be > reduced
    end
  end

  describe '#critical_period' do
    it 'starts as false' do
      expect(engine.critical_period?).to be false
    end

    it 'can be entered and exited' do
      engine.enter_critical_period!
      expect(engine.critical_period?).to be true
      engine.exit_critical_period!
      expect(engine.critical_period?).to be false
    end

    it 'amplifies strengthening during critical period' do
      p1 = engine.create_pathway(label: 'normal')
      engine.strengthen_pathway(pathway_id: p1.id)
      normal_strength = p1.strength

      engine.enter_critical_period!
      p2 = engine.create_pathway(label: 'boosted')
      engine.strengthen_pathway(pathway_id: p2.id)
      expect(p2.strength).to be > normal_strength
    end
  end

  describe '#prune_weak_pathways!' do
    it 'removes pathways below threshold' do
      engine.create_pathway(label: 'weak', initial_strength: 0.05)
      engine.create_pathway(label: 'strong', initial_strength: 0.8)
      pruned = engine.prune_weak_pathways!
      expect(pruned).to eq(1)
      expect(engine.to_h[:total_pathways]).to eq(1)
    end
  end

  describe '#pathways_by_type' do
    it 'filters by type' do
      engine.create_pathway(label: 'a', pathway_type: :structural)
      engine.create_pathway(label: 'b', pathway_type: :synaptic)
      result = engine.pathways_by_type(pathway_type: :structural)
      expect(result.size).to eq(1)
    end
  end

  describe '#strongest_pathways' do
    it 'returns pathways sorted by strength descending' do
      engine.create_pathway(label: 'weak', initial_strength: 0.2)
      engine.create_pathway(label: 'strong', initial_strength: 0.9)
      strongest = engine.strongest_pathways(limit: 1)
      expect(strongest.first.label).to eq('strong')
    end
  end

  describe '#weakest_pathways' do
    it 'returns pathways sorted by strength ascending' do
      engine.create_pathway(label: 'weak', initial_strength: 0.2)
      engine.create_pathway(label: 'strong', initial_strength: 0.9)
      weakest = engine.weakest_pathways(limit: 1)
      expect(weakest.first.label).to eq('weak')
    end
  end

  describe '#average_strength' do
    it 'returns 0.0 with no pathways' do
      expect(engine.average_strength).to eq(0.0)
    end

    it 'computes average across pathways' do
      engine.create_pathway(label: 'a', initial_strength: 0.2)
      engine.create_pathway(label: 'b', initial_strength: 0.8)
      expect(engine.average_strength).to eq(0.5)
    end
  end

  describe '#average_plasticity' do
    it 'returns default with no pathways' do
      default = Legion::Extensions::Agentic::Learning::Plasticity::Helpers::Constants::DEFAULT_LEARNING_RATE
      expect(engine.average_plasticity).to eq(default)
    end
  end

  describe '#plasticity_report' do
    it 'includes all report fields' do
      pathway
      report = engine.plasticity_report
      expect(report).to include(
        :total_pathways, :critical_period, :average_strength,
        :average_plasticity, :prune_candidates, :strongest
      )
    end
  end

  describe '#to_h' do
    it 'includes summary fields' do
      hash = engine.to_h
      expect(hash).to include(
        :total_pathways, :critical_period, :average_strength,
        :average_plasticity, :prune_candidates
      )
    end
  end

  describe 'pruning' do
    it 'prunes weakest pathway when limit reached' do
      stub_const('Legion::Extensions::Agentic::Learning::Plasticity::Helpers::Constants::MAX_PATHWAYS', 3)
      eng = described_class.new
      4.times { |i| eng.create_pathway(label: "p#{i}", initial_strength: (i + 1) * 0.2) }
      expect(eng.to_h[:total_pathways]).to eq(3)
    end
  end
end
