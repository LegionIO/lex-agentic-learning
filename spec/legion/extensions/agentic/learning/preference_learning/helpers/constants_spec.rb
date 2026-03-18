# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::PreferenceLearning::Helpers::Constants do
  describe 'PREFERENCE_LABELS' do
    subject(:labels) { described_class::PREFERENCE_LABELS }

    it 'labels 0.9 as strongly_preferred' do
      label = labels.find { |range, _| range.cover?(0.9) }&.last
      expect(label).to eq(:strongly_preferred)
    end

    it 'labels 0.7 as preferred' do
      label = labels.find { |range, _| range.cover?(0.7) }&.last
      expect(label).to eq(:preferred)
    end

    it 'labels 0.5 as neutral' do
      label = labels.find { |range, _| range.cover?(0.5) }&.last
      expect(label).to eq(:neutral)
    end

    it 'labels 0.3 as disliked' do
      label = labels.find { |range, _| range.cover?(0.3) }&.last
      expect(label).to eq(:disliked)
    end

    it 'labels 0.1 as strongly_disliked' do
      label = labels.find { |range, _| range.cover?(0.1) }&.last
      expect(label).to eq(:strongly_disliked)
    end
  end

  describe 'numeric constants' do
    it 'defines MAX_OPTIONS' do
      expect(described_class::MAX_OPTIONS).to eq(200)
    end

    it 'defines MAX_COMPARISONS' do
      expect(described_class::MAX_COMPARISONS).to eq(1000)
    end

    it 'defines MAX_HISTORY' do
      expect(described_class::MAX_HISTORY).to eq(500)
    end

    it 'defines DEFAULT_PREFERENCE as 0.5' do
      expect(described_class::DEFAULT_PREFERENCE).to eq(0.5)
    end

    it 'defines PREFERENCE_FLOOR as 0.0' do
      expect(described_class::PREFERENCE_FLOOR).to eq(0.0)
    end

    it 'defines PREFERENCE_CEILING as 1.0' do
      expect(described_class::PREFERENCE_CEILING).to eq(1.0)
    end

    it 'WIN_BOOST is greater than LOSS_PENALTY inverted' do
      expect(described_class::WIN_BOOST).to eq(0.08)
      expect(described_class::LOSS_PENALTY).to eq(0.06)
    end

    it 'defines DECAY_RATE' do
      expect(described_class::DECAY_RATE).to eq(0.01)
    end
  end
end
