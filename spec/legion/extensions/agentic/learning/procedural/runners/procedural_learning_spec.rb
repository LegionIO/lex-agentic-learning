# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::Procedural::Runners::ProceduralLearning do
  let(:runner_host) do
    obj = Object.new
    obj.extend(described_class)
    obj
  end

  describe '#create_skill' do
    it 'creates a skill' do
      result = runner_host.create_skill(name: 'api_retry', domain: :http)
      expect(result[:success]).to be true
      expect(result[:skill_id]).to be_a(String)
    end
  end

  describe '#add_skill_production' do
    it 'adds a production to a skill' do
      created = runner_host.create_skill(name: 'test', domain: :test)
      result = runner_host.add_skill_production(
        skill_id: created[:skill_id], condition: 'if_error',
        action: 'retry', domain: :test
      )
      expect(result[:success]).to be true
    end
  end

  describe '#practice_skill' do
    it 'increases proficiency' do
      created = runner_host.create_skill(name: 'test', domain: :test)
      result = runner_host.practice_skill(skill_id: created[:skill_id], success: true)
      expect(result[:success]).to be true
      expect(result[:proficiency]).to be > 0.1
    end
  end

  describe '#execute_production' do
    it 'executes a production' do
      created = runner_host.create_skill(name: 'test', domain: :test)
      prod = runner_host.add_skill_production(
        skill_id: created[:skill_id], condition: 'test',
        action: 'act', domain: :test
      )
      result = runner_host.execute_production(production_id: prod[:production_id], success: true)
      expect(result[:success]).to be true
    end
  end

  describe '#skill_assessment' do
    it 'returns skill assessment' do
      created = runner_host.create_skill(name: 'test', domain: :test)
      result = runner_host.skill_assessment(skill_id: created[:skill_id])
      expect(result[:success]).to be true
    end
  end

  describe '#compiled_skills' do
    it 'returns compiled skills' do
      result = runner_host.compiled_skills
      expect(result[:success]).to be true
    end
  end

  describe '#autonomous_skills' do
    it 'returns autonomous skills' do
      result = runner_host.autonomous_skills
      expect(result[:success]).to be true
    end
  end

  describe '#most_practiced_skills' do
    it 'returns most practiced skills' do
      result = runner_host.most_practiced_skills(limit: 3)
      expect(result[:success]).to be true
    end
  end

  describe '#update_procedural_learning' do
    it 'runs decay and prune cycle' do
      result = runner_host.update_procedural_learning
      expect(result[:success]).to be true
      expect(result).to include(:pruned)
    end
  end

  describe '#procedural_learning_stats' do
    it 'returns stats' do
      result = runner_host.procedural_learning_stats
      expect(result[:success]).to be true
      expect(result).to include(:total_skills, :total_productions)
    end
  end
end
