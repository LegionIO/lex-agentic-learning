# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::Procedural::Client do
  subject(:client) { described_class.new }

  it 'creates a skill' do
    result = client.create_skill(name: 'test', domain: :test)
    expect(result[:success]).to be true
  end

  it 'practices and compiles a skill' do
    created = client.create_skill(name: 'test', domain: :test)
    8.times { client.practice_skill(skill_id: created[:skill_id], success: true) }
    compiled = client.compiled_skills
    expect(compiled[:count]).to eq(1)
  end

  it 'returns stats' do
    result = client.procedural_learning_stats
    expect(result[:success]).to be true
  end
end
