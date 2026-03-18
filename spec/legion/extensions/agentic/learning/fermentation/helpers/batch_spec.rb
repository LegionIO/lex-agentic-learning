# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::Fermentation::Helpers::Batch do
  subject(:batch) { described_class.new(domain: :cognitive) }

  let(:substrate_class) { Legion::Extensions::Agentic::Learning::Fermentation::Helpers::Substrate }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(batch.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'stores domain' do
      expect(batch.domain).to eq(:cognitive)
    end

    it 'starts with empty substrates' do
      expect(batch.substrates).to be_empty
    end
  end

  describe '#add_substrate' do
    it 'adds substrate to batch' do
      sub = substrate_class.new(substrate_type: :raw_idea, domain: :cognitive)
      batch.add_substrate(sub)
      expect(batch.substrates.size).to eq(1)
    end
  end

  describe '#ferment_all!' do
    it 'ferments all substrates' do
      sub = substrate_class.new(substrate_type: :raw_idea, domain: :cognitive)
      batch.add_substrate(sub)
      batch.ferment_all!
      expect(sub.maturity).to be > 0.0
    end
  end

  describe '#average_potency' do
    it 'returns 0.0 for empty batch' do
      expect(batch.average_potency).to eq(0.0)
    end

    it 'computes average' do
      s1 = substrate_class.new(substrate_type: :raw_idea, domain: :cognitive, potency: 0.6)
      s2 = substrate_class.new(substrate_type: :raw_idea, domain: :cognitive, potency: 0.4)
      batch.add_substrate(s1)
      batch.add_substrate(s2)
      expect(batch.average_potency).to eq(0.5)
    end
  end

  describe '#yield_rate' do
    it 'returns 0.0 for empty batch' do
      expect(batch.yield_rate).to eq(0.0)
    end
  end

  describe '#ready_to_harvest?' do
    it 'returns false when no ripe substrates' do
      expect(batch).not_to be_ready_to_harvest
    end
  end

  describe '#to_h' do
    it 'returns hash with batch stats' do
      h = batch.to_h
      expect(h).to include(:id, :domain, :substrate_count, :average_potency,
                           :average_maturity, :ripe_count, :yield_rate)
    end
  end
end
