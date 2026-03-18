# frozen_string_literal: true

require 'legion/extensions/agentic/learning/preference_learning/client'

RSpec.describe Legion::Extensions::Agentic::Learning::PreferenceLearning::Client do
  let(:client) { described_class.new }

  it 'responds to runner methods' do
    expect(client).to respond_to(:register_preference_option)
    expect(client).to respond_to(:record_preference_comparison)
    expect(client).to respond_to(:predict_preference_outcome)
    expect(client).to respond_to(:top_preferences_report)
    expect(client).to respond_to(:preference_stability_report)
    expect(client).to respond_to(:update_preference_learning)
    expect(client).to respond_to(:preference_learning_stats)
  end
end
