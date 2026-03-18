# frozen_string_literal: true

require 'legion/extensions/agentic/learning/preference_learning/client'

RSpec.describe Legion::Extensions::Agentic::Learning::PreferenceLearning::Runners::PreferenceLearning do
  let(:client) { Legion::Extensions::Agentic::Learning::PreferenceLearning::Client.new }

  let(:opt_a_id) { client.register_preference_option(label: 'Alpha', domain: :general)[:id] }
  let(:opt_b_id) { client.register_preference_option(label: 'Beta', domain: :general)[:id] }

  describe '#register_preference_option' do
    it 'registers an option and returns id' do
      result = client.register_preference_option(label: 'Gamma')
      expect(result[:id]).not_to be_nil
      expect(result[:label]).to eq('Gamma')
    end
  end

  describe '#record_preference_comparison' do
    it 'records winner/loser and returns comparison data' do
      result = client.record_preference_comparison(winner_id: opt_a_id, loser_id: opt_b_id)
      expect(result[:comparisons]).to eq(1)
      expect(result[:winner_score]).to be > 0.5
    end

    it 'returns error for invalid ids' do
      result = client.record_preference_comparison(winner_id: 'nope', loser_id: opt_b_id)
      expect(result[:error]).to eq('option not found')
    end
  end

  describe '#predict_preference_outcome' do
    it 'returns preferred_id and confidence' do
      3.times { client.record_preference_comparison(winner_id: opt_a_id, loser_id: opt_b_id) }
      result = client.predict_preference_outcome(option_a_id: opt_a_id, option_b_id: opt_b_id)
      expect(result[:preferred_id]).to eq(opt_a_id)
      expect(result[:confidence]).to be_between(0.0, 1.0)
    end

    it 'returns error for invalid id' do
      result = client.predict_preference_outcome(option_a_id: 'bad', option_b_id: opt_b_id)
      expect(result[:error]).to eq('option not found')
    end
  end

  describe '#top_preferences_report' do
    it 'returns domain, limit, and options array' do
      opt_a_id
      opt_b_id
      result = client.top_preferences_report(domain: :general, limit: 5)
      expect(result[:domain]).to eq(:general)
      expect(result[:limit]).to eq(5)
      expect(result[:options]).to be_an(Array)
    end
  end

  describe '#preference_stability_report' do
    it 'returns stability float and label' do
      opt_a_id
      opt_b_id
      result = client.preference_stability_report
      expect(result[:stability]).to be_a(Float)
      expect(%i[stable variable]).to include(result[:label])
    end
  end

  describe '#update_preference_learning' do
    it 'returns decayed count' do
      opt_a_id
      opt_b_id
      result = client.update_preference_learning
      expect(result[:decayed]).to eq(2)
    end
  end

  describe '#preference_learning_stats' do
    it 'returns total_options, comparisons, stability, stability_label' do
      opt_a_id
      opt_b_id
      result = client.preference_learning_stats
      expect(result[:total_options]).to eq(2)
      expect(result[:comparisons]).to eq(0)
      expect(result[:stability_label]).not_to be_nil
    end
  end
end
