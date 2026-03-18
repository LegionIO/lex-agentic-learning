# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::Fermentation::Helpers::FermentationEngine do
  subject(:engine) { described_class.new }

  describe '#create_substrate' do
    it 'creates and returns a substrate' do
      sub = engine.create_substrate(substrate_type: :raw_idea, domain: :cognitive)
      expect(sub).to be_a(Legion::Extensions::Agentic::Learning::Fermentation::Helpers::Substrate)
    end

    it 'adds substrate to a batch' do
      engine.create_substrate(substrate_type: :raw_idea, domain: :cognitive)
      report = engine.fermentation_report
      expect(report[:total_batches]).to eq(1)
    end

    it 'reuses batch for same domain' do
      engine.create_substrate(substrate_type: :raw_idea, domain: :cognitive)
      engine.create_substrate(substrate_type: :dormant_association, domain: :cognitive)
      expect(engine.fermentation_report[:total_batches]).to eq(1)
    end

    it 'creates separate batches per domain' do
      engine.create_substrate(substrate_type: :raw_idea, domain: :cognitive)
      engine.create_substrate(substrate_type: :raw_idea, domain: :emotional)
      expect(engine.fermentation_report[:total_batches]).to eq(2)
    end

    it 'rejects invalid substrate_type' do
      expect(engine.create_substrate(substrate_type: :telekinesis, domain: :cognitive)).to be_nil
    end

    it 'accepts all valid SUBSTRATE_TYPES' do
      constants = Legion::Extensions::Agentic::Learning::Fermentation::Helpers::Constants
      constants::SUBSTRATE_TYPES.each do |st|
        result = engine.create_substrate(substrate_type: st, domain: :cognitive)
        expect(result).not_to be_nil
      end
    end
  end

  describe '#ferment' do
    it 'ferments an existing substrate' do
      sub = engine.create_substrate(substrate_type: :raw_idea, domain: :cognitive)
      result = engine.ferment(substrate_id: sub.id)
      expect(result.maturity).to be > 0.0
    end

    it 'returns nil for unknown substrate' do
      expect(engine.ferment(substrate_id: 'nonexistent')).to be_nil
    end
  end

  describe '#catalyze' do
    it 'catalyzes an existing substrate' do
      sub = engine.create_substrate(substrate_type: :raw_idea, domain: :cognitive, potency: 0.3)
      result = engine.catalyze(substrate_id: sub.id, catalyst_type: :analogy)
      expect(result.potency).to be > 0.3
    end

    it 'returns nil for unknown substrate' do
      expect(engine.catalyze(substrate_id: 'x', catalyst_type: :analogy)).to be_nil
    end

    it 'rejects invalid catalyst_type' do
      sub = engine.create_substrate(substrate_type: :raw_idea, domain: :cognitive)
      expect(engine.catalyze(substrate_id: sub.id, catalyst_type: :magic)).to be_nil
    end

    it 'accepts all valid CATALYST_TYPES' do
      constants = Legion::Extensions::Agentic::Learning::Fermentation::Helpers::Constants
      sub = engine.create_substrate(substrate_type: :raw_idea, domain: :cognitive, potency: 0.1)
      constants::CATALYST_TYPES.each do |ct|
        result = engine.catalyze(substrate_id: sub.id, catalyst_type: ct)
        expect(result).not_to be_nil
      end
    end
  end

  describe '#ferment_all!' do
    it 'advances all substrates' do
      s1 = engine.create_substrate(substrate_type: :raw_idea, domain: :cognitive)
      s2 = engine.create_substrate(substrate_type: :raw_idea, domain: :emotional)
      engine.ferment_all!
      expect(s1.maturity).to be > 0.0
      expect(s2.maturity).to be > 0.0
    end
  end

  describe 'query methods' do
    before do
      engine.create_substrate(substrate_type: :raw_idea, domain: :cognitive, potency: 0.5)
      engine.create_substrate(substrate_type: :dormant_association, domain: :emotional, potency: 0.3)
      engine.create_substrate(substrate_type: :raw_idea, domain: :cognitive, potency: 0.8)
    end

    it 'filters by domain' do
      expect(engine.substrates_by_domain(domain: :cognitive).size).to eq(2)
    end

    it 'filters by type' do
      expect(engine.substrates_by_type(type: :raw_idea).size).to eq(2)
    end

    it 'filters by stage' do
      expect(engine.substrates_by_stage(stage: :inoculation).size).to eq(3)
    end

    it 'returns raw substrates' do
      expect(engine.raw_substrates.size).to eq(3)
    end

    it 'returns most potent' do
      results = engine.most_potent(limit: 2)
      expect(results.size).to eq(2)
      expect(results.first.potency).to be >= results.last.potency
    end
  end

  describe 'aggregate metrics' do
    it 'returns 0.0 overall_potency for empty engine' do
      expect(engine.overall_potency).to eq(0.0)
    end

    it 'computes overall_potency' do
      engine.create_substrate(substrate_type: :raw_idea, domain: :cognitive, potency: 0.6)
      expect(engine.overall_potency).to be > 0.0
    end

    it 'computes overall_maturity' do
      sub = engine.create_substrate(substrate_type: :raw_idea, domain: :cognitive)
      engine.ferment(substrate_id: sub.id)
      expect(engine.overall_maturity).to be > 0.0
    end

    it 'computes yield_rate' do
      expect(engine.yield_rate).to eq(0.0)
    end

    it 'computes stage_distribution' do
      engine.create_substrate(substrate_type: :raw_idea, domain: :cognitive)
      dist = engine.stage_distribution
      expect(dist[:inoculation]).to eq(1)
    end
  end

  describe '#fermentation_report' do
    it 'returns comprehensive report' do
      engine.create_substrate(substrate_type: :raw_idea, domain: :cognitive, potency: 0.5)
      report = engine.fermentation_report
      expect(report).to include(:total_substrates, :total_batches, :overall_potency,
                                :potency_label, :overall_maturity, :maturity_label,
                                :yield_rate, :stage_distribution, :batches, :most_potent)
    end
  end

  describe '#to_h' do
    it 'returns summary hash' do
      h = engine.to_h
      expect(h).to include(:total_substrates, :total_batches, :potency, :maturity, :volatility)
    end
  end
end
