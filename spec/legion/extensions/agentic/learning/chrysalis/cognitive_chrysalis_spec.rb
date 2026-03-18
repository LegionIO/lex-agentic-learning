# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::Chrysalis do
  it 'has a version number' do
    expect(Legion::Extensions::Agentic::Learning::Chrysalis::VERSION).not_to be_nil
  end

  it 'has a version that is a string' do
    expect(Legion::Extensions::Agentic::Learning::Chrysalis::VERSION).to be_a(String)
  end

  it 'version is 0.1.0' do
    expect(Legion::Extensions::Agentic::Learning::Chrysalis::VERSION).to eq('0.1.0')
  end
end
