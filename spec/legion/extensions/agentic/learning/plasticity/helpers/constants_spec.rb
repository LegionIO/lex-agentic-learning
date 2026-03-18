# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::Plasticity::Helpers::Constants do
  let(:klass) { Class.new { include Legion::Extensions::Agentic::Learning::Plasticity::Helpers::Constants } }

  describe 'PLASTICITY_LABELS' do
    it 'is a frozen hash' do
      expect(klass::PLASTICITY_LABELS).to be_a(Hash).and be_frozen
    end

    it 'covers the full 0..1 range' do
      labels = klass::PLASTICITY_LABELS
      [0.0, 0.3, 0.5, 0.7, 0.9].each do |val|
        match = labels.find { |range, _| range.cover?(val) }
        expect(match).not_to be_nil, "no label for #{val}"
      end
    end
  end

  describe 'STRENGTH_LABELS' do
    it 'is a frozen hash' do
      expect(klass::STRENGTH_LABELS).to be_a(Hash).and be_frozen
    end
  end

  describe 'PATHWAY_TYPES' do
    it 'is a frozen array of symbols' do
      expect(klass::PATHWAY_TYPES).to be_a(Array).and be_frozen
      expect(klass::PATHWAY_TYPES).to all(be_a(Symbol))
    end

    it 'includes synaptic' do
      expect(klass::PATHWAY_TYPES).to include(:synaptic)
    end
  end

  describe 'numeric constants' do
    it 'has positive MAX_PATHWAYS' do
      expect(klass::MAX_PATHWAYS).to be > 0
    end

    it 'has STRENGTHENING_RATE between 0 and 1' do
      expect(klass::STRENGTHENING_RATE).to be_between(0.0, 1.0)
    end

    it 'has CRITICAL_PERIOD_MULTIPLIER > 1' do
      expect(klass::CRITICAL_PERIOD_MULTIPLIER).to be > 1.0
    end

    it 'has PRUNING_THRESHOLD between 0 and 1' do
      expect(klass::PRUNING_THRESHOLD).to be_between(0.0, 1.0)
    end
  end
end
