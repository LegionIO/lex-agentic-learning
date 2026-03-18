# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::Plasticity::Helpers::NeuralPathway do
  subject(:pathway) { described_class.new(label: 'test_pathway') }

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(pathway.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets label' do
      expect(pathway.label).to eq('test_pathway')
    end

    it 'defaults to synaptic type' do
      expect(pathway.pathway_type).to eq(:synaptic)
    end

    it 'starts with default strength' do
      expect(pathway.strength).to eq(0.3)
    end

    it 'starts with default learning rate as plasticity' do
      default = Legion::Extensions::Agentic::Learning::Plasticity::Helpers::Constants::DEFAULT_LEARNING_RATE
      expect(pathway.plasticity).to eq(default)
    end

    it 'starts with 0 activations' do
      expect(pathway.activation_count).to eq(0)
    end

    it 'clamps initial strength to 0..1' do
      high = described_class.new(label: 'h', initial_strength: 5.0)
      expect(high.strength).to eq(1.0)
    end
  end

  describe '#strengthen!' do
    it 'increases strength' do
      original = pathway.strength
      pathway.strengthen!
      expect(pathway.strength).to be > original
    end

    it 'increments activation_count' do
      pathway.strengthen!
      expect(pathway.activation_count).to eq(1)
    end

    it 'clamps at 1.0' do
      p = described_class.new(label: 'strong', initial_strength: 0.99)
      p.strengthen!(amount: 0.5)
      expect(p.strength).to eq(1.0)
    end

    it 'applies critical period multiplier' do
      p1 = described_class.new(label: 'normal')
      p2 = described_class.new(label: 'critical')
      p1.strengthen!(amount: 0.1)
      p2.strengthen!(amount: 0.1, critical_period: true)
      expect(p2.strength).to be > p1.strength
    end

    it 'returns self' do
      expect(pathway.strengthen!).to eq(pathway)
    end

    it 'reduces plasticity (maturation)' do
      original_plasticity = pathway.plasticity
      pathway.strengthen!
      expect(pathway.plasticity).to be < original_plasticity
    end
  end

  describe '#weaken!' do
    it 'decreases strength' do
      original = pathway.strength
      pathway.weaken!
      expect(pathway.strength).to be < original
    end

    it 'clamps at 0.0' do
      p = described_class.new(label: 'weak', initial_strength: 0.01)
      p.weaken!(amount: 0.5)
      expect(p.strength).to eq(0.0)
    end
  end

  describe '#prune_candidate?' do
    it 'is false for moderate strength' do
      expect(pathway.prune_candidate?).to be false
    end

    it 'is true for very weak pathways' do
      p = described_class.new(label: 'tiny', initial_strength: 0.1)
      expect(p.prune_candidate?).to be true
    end
  end

  describe '#rejuvenate!' do
    it 'increases plasticity' do
      pathway.strengthen!
      reduced = pathway.plasticity
      pathway.rejuvenate!(amount: 0.2)
      expect(pathway.plasticity).to be > reduced
    end

    it 'clamps at 1.0' do
      pathway.rejuvenate!(amount: 5.0)
      expect(pathway.plasticity).to eq(1.0)
    end
  end

  describe '#strength_label' do
    it 'returns a symbol' do
      expect(pathway.strength_label).to be_a(Symbol)
    end
  end

  describe '#plasticity_label' do
    it 'returns a symbol' do
      expect(pathway.plasticity_label).to be_a(Symbol)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      hash = pathway.to_h
      expect(hash).to include(
        :id, :label, :pathway_type, :strength, :strength_label,
        :plasticity, :plasticity_label, :activation_count,
        :prune_candidate, :created_at
      )
    end
  end
end
