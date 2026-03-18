# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::Fermentation::Helpers::Substrate do
  subject(:substrate) do
    described_class.new(substrate_type: :raw_idea, domain: :cognitive, content: 'test idea')
  end

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(substrate.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores substrate_type as symbol' do
      expect(substrate.substrate_type).to eq(:raw_idea)
    end

    it 'stores domain as symbol' do
      expect(substrate.domain).to eq(:cognitive)
    end

    it 'stores content' do
      expect(substrate.content).to eq('test idea')
    end

    it 'defaults potency' do
      expect(substrate.potency).to eq(0.3)
    end

    it 'starts at inoculation stage' do
      expect(substrate.stage).to eq(:inoculation)
    end

    it 'starts with zero maturity' do
      expect(substrate.maturity).to eq(0.0)
    end

    it 'starts with empty catalysts' do
      expect(substrate.catalysts_applied).to be_empty
    end

    it 'clamps potency to valid range' do
      s = described_class.new(substrate_type: :raw_idea, domain: :cognitive, potency: 1.5)
      expect(s.potency).to eq(1.0)
    end
  end

  describe '#ferment!' do
    it 'increases maturity' do
      substrate.ferment!
      expect(substrate.maturity).to be > 0.0
    end

    it 'decreases volatility' do
      initial = substrate.volatility
      substrate.ferment!
      expect(substrate.volatility).to be < initial
    end

    it 'advances stage with enough fermentation' do
      5.times { substrate.ferment!(0.1) }
      expect(substrate.stage).not_to eq(:inoculation)
    end

    it 'reaches peak stage' do
      18.times { substrate.ferment!(0.05) }
      expect(substrate.stage).to eq(:peak)
    end

    it 'reaches over_fermented stage' do
      25.times { substrate.ferment!(0.05) }
      expect(substrate.stage).to eq(:over_fermented)
    end
  end

  describe '#catalyze!' do
    it 'boosts potency' do
      initial = substrate.potency
      substrate.catalyze!(:analogy)
      expect(substrate.potency).to be > initial
    end

    it 'records catalyst type' do
      substrate.catalyze!(:dream_residue)
      expect(substrate.catalysts_applied).to include(:dream_residue)
    end

    it 'slightly increases volatility' do
      initial = substrate.volatility
      substrate.catalyze!(:analogy)
      expect(substrate.volatility).to be > initial
    end
  end

  describe '#spoil!' do
    it 'halves potency' do
      initial = substrate.potency
      substrate.spoil!
      expect(substrate.potency).to be < initial
    end

    it 'sets stage to over_fermented' do
      substrate.spoil!
      expect(substrate.stage).to eq(:over_fermented)
    end
  end

  describe 'predicate methods' do
    it 'reports ripe when potency and maturity are high' do
      s = described_class.new(substrate_type: :raw_idea, domain: :cognitive, potency: 0.8)
      10.times { s.ferment!(0.06) }
      expect(s).to be_ripe
    end

    it 'reports spoiled when potency is very low' do
      s = described_class.new(substrate_type: :raw_idea, domain: :cognitive, potency: 0.05)
      s.spoil!
      expect(s).to be_spoiled
    end

    it 'reports raw at inoculation' do
      expect(substrate).to be_raw
    end

    it 'reports multi_catalyzed with 3+ catalysts' do
      substrate.catalyze!(:analogy)
      substrate.catalyze!(:contrast)
      substrate.catalyze!(:dream_residue)
      expect(substrate).to be_multi_catalyzed
    end
  end

  describe '#age' do
    it 'returns age in minutes' do
      expect(substrate.age).to be >= 0.0
    end
  end

  describe '#to_h' do
    it 'returns hash with all fields' do
      h = substrate.to_h
      expect(h).to include(:id, :substrate_type, :domain, :content, :potency,
                           :maturity, :volatility, :stage, :ripe, :peak,
                           :spoiled, :catalysts_applied, :created_at)
    end
  end
end
