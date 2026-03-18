# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::PreferenceLearning::Helpers::Option do
  subject(:option) { described_class.new(label: 'Option A', domain: :taste) }

  describe '#initialize' do
    it 'assigns a uuid id' do
      expect(option.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets label and domain' do
      expect(option.label).to eq('Option A')
      expect(option.domain).to eq(:taste)
    end

    it 'starts with default preference score' do
      expect(option.preference_score).to eq(0.5)
    end

    it 'starts with zero wins and losses' do
      expect(option.wins).to eq(0)
      expect(option.losses).to eq(0)
      expect(option.times_seen).to eq(0)
    end

    it 'records created_at' do
      expect(option.created_at).to be_a(Time)
    end
  end

  describe '#win!' do
    it 'increments wins and times_seen' do
      option.win!
      expect(option.wins).to eq(1)
      expect(option.times_seen).to eq(1)
    end

    it 'increases preference score' do
      before = option.preference_score
      option.win!
      expect(option.preference_score).to be > before
    end

    it 'does not exceed ceiling' do
      20.times { option.win! }
      expect(option.preference_score).to be <= 1.0
    end
  end

  describe '#lose!' do
    it 'increments losses and times_seen' do
      option.lose!
      expect(option.losses).to eq(1)
      expect(option.times_seen).to eq(1)
    end

    it 'decreases preference score' do
      before = option.preference_score
      option.lose!
      expect(option.preference_score).to be < before
    end

    it 'does not go below floor' do
      20.times { option.lose! }
      expect(option.preference_score).to be >= 0.0
    end
  end

  describe '#win_rate' do
    it 'returns 0.0 when no comparisons' do
      expect(option.win_rate).to eq(0.0)
    end

    it 'returns a value between 0 and 1 after comparisons' do
      option.win!
      option.lose!
      expect(option.win_rate).to be_between(0.0, 1.0)
    end
  end

  describe '#preference_label' do
    it 'returns :neutral for default score' do
      expect(option.preference_label).to eq(:neutral)
    end

    it 'returns :strongly_preferred after many wins' do
      15.times { option.win! }
      expect(option.preference_label).to eq(:strongly_preferred)
    end

    it 'returns :strongly_disliked after many losses' do
      15.times { option.lose! }
      expect(option.preference_label).to eq(:strongly_disliked)
    end
  end

  describe '#to_h' do
    it 'includes all expected keys' do
      h = option.to_h
      expect(h.keys).to include(:id, :label, :domain, :preference_score, :wins, :losses,
                                :times_seen, :win_rate, :preference_label, :created_at)
    end
  end
end
