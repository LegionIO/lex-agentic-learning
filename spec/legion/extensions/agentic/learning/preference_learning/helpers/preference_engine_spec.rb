# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::PreferenceLearning::Helpers::PreferenceEngine do
  subject(:engine) { described_class.new }

  let(:opt_a_id) { engine.register_option(label: 'Apple', domain: :food)[:id] }
  let(:opt_b_id) { engine.register_option(label: 'Banana', domain: :food)[:id] }

  describe '#register_option' do
    it 'returns a hash with id, label, domain' do
      result = engine.register_option(label: 'Cherry', domain: :food)
      expect(result[:id]).to match(/\A[0-9a-f-]{36}\z/)
      expect(result[:label]).to eq('Cherry')
      expect(result[:domain]).to eq(:food)
    end

    it 'starts with default preference score' do
      result = engine.register_option(label: 'Date')
      expect(result[:preference_score]).to eq(0.5)
    end
  end

  describe '#record_comparison' do
    it 'increases winner score and decreases loser score' do
      engine.record_comparison(winner_id: opt_a_id, loser_id: opt_b_id)
      top = engine.top_preferences(domain: :food, limit: 1)
      expect(top.first[:id]).to eq(opt_a_id)
    end

    it 'returns comparison summary' do
      result = engine.record_comparison(winner_id: opt_a_id, loser_id: opt_b_id)
      expect(result[:comparisons]).to eq(1)
      expect(result[:winner_score]).to be > 0.5
      expect(result[:loser_score]).to be < 0.5
    end

    it 'returns error for unknown option' do
      result = engine.record_comparison(winner_id: 'bad-id', loser_id: opt_b_id)
      expect(result[:error]).to eq('option not found')
    end
  end

  describe '#predict_preference' do
    it 'predicts winner after comparisons' do
      3.times { engine.record_comparison(winner_id: opt_a_id, loser_id: opt_b_id) }
      result = engine.predict_preference(option_a_id: opt_a_id, option_b_id: opt_b_id)
      expect(result[:preferred_id]).to eq(opt_a_id)
    end

    it 'returns confidence as a 0..1 value' do
      engine.record_comparison(winner_id: opt_a_id, loser_id: opt_b_id)
      result = engine.predict_preference(option_a_id: opt_a_id, option_b_id: opt_b_id)
      expect(result[:confidence]).to be_between(0.0, 1.0)
    end

    it 'returns error for unknown option' do
      result = engine.predict_preference(option_a_id: 'bad-id', option_b_id: opt_b_id)
      expect(result[:error]).to eq('option not found')
    end
  end

  describe '#top_preferences' do
    it 'returns options sorted by score descending' do
      engine.record_comparison(winner_id: opt_a_id, loser_id: opt_b_id)
      top = engine.top_preferences(domain: :food, limit: 2)
      expect(top.first[:id]).to eq(opt_a_id)
    end

    it 'respects limit' do
      3.times { engine.register_option(label: "opt#{it}") }
      top = engine.top_preferences(limit: 2)
      expect(top.size).to be <= 2
    end

    it 'returns all domains when domain is nil' do
      opt_a_id
      engine.register_option(label: 'X', domain: :color)
      result = engine.top_preferences(domain: nil, limit: 10)
      domains = result.map { |o| o[:domain] }.uniq
      expect(domains).to include(:food, :color)
    end
  end

  describe '#bottom_preferences' do
    it 'returns options sorted by score ascending' do
      engine.record_comparison(winner_id: opt_a_id, loser_id: opt_b_id)
      bottom = engine.bottom_preferences(domain: :food, limit: 1)
      expect(bottom.first[:id]).to eq(opt_b_id)
    end
  end

  describe '#preferences_by_domain' do
    it 'returns only options for given domain' do
      fresh = described_class.new
      fresh.register_option(label: 'Apple', domain: :food)
      fresh.register_option(label: 'Red', domain: :color)
      result = fresh.preferences_by_domain(domain: :food)
      expect(result.map { |o| o[:domain] }.uniq).to eq([:food])
    end
  end

  describe '#preference_stability' do
    it 'returns 0.0 with fewer than 2 options' do
      engine2 = described_class.new
      engine2.register_option(label: 'Solo')
      expect(engine2.preference_stability).to eq(0.0)
    end

    it 'returns a non-negative float with multiple options' do
      opt_a_id
      opt_b_id
      3.times { engine.record_comparison(winner_id: opt_a_id, loser_id: opt_b_id) }
      expect(engine.preference_stability).to be >= 0.0
    end
  end

  describe '#most_compared' do
    it 'returns options sorted by times_seen descending' do
      3.times { engine.record_comparison(winner_id: opt_a_id, loser_id: opt_b_id) }
      result = engine.most_compared(limit: 2)
      expect(result.first[:times_seen]).to be >= result.last[:times_seen]
    end
  end

  describe '#decay_all' do
    it 'returns the count of options' do
      opt_a_id
      opt_b_id
      expect(engine.decay_all).to eq(2)
    end

    it 'nudges scores toward default (0.5)' do
      3.times { engine.record_comparison(winner_id: opt_a_id, loser_id: opt_b_id) }
      before_a = engine.top_preferences(domain: :food, limit: 1).first[:preference_score]
      engine.decay_all
      after_a = engine.top_preferences(domain: :food, limit: 1).first[:preference_score]
      expect(after_a).to be < before_a
    end
  end

  describe '#to_h' do
    it 'includes total_options, comparisons, stability, options' do
      opt_a_id
      opt_b_id
      h = engine.to_h
      expect(h[:total_options]).to eq(2)
      expect(h[:comparisons]).to eq(0)
      expect(h[:options]).to be_an(Array)
    end
  end
end
