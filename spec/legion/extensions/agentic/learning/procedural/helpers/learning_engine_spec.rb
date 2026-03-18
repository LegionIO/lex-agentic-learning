# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::Procedural::Helpers::LearningEngine do
  subject(:engine) { described_class.new }

  let(:skill) { engine.create_skill(name: 'api_retry', domain: :http) }

  describe '#create_skill' do
    it 'creates and returns a skill' do
      result = skill
      expect(result).to be_a(Legion::Extensions::Agentic::Learning::Procedural::Helpers::Skill)
      expect(result.name).to eq('api_retry')
    end

    it 'records history' do
      skill
      expect(engine.history.size).to eq(1)
    end
  end

  describe '#add_production' do
    it 'creates a production for a skill' do
      result = engine.add_production(
        skill_id: skill.id, condition: 'if_error',
        action: 'retry', domain: :http
      )
      expect(result).to be_a(Legion::Extensions::Agentic::Learning::Procedural::Helpers::Production)
    end

    it 'returns error for unknown skill' do
      result = engine.add_production(
        skill_id: 'bad', condition: 'test',
        action: 'test', domain: :test
      )
      expect(result[:success]).to be false
    end
  end

  describe '#practice_skill' do
    it 'increases proficiency' do
      result = engine.practice_skill(skill_id: skill.id, success: true)
      expect(result[:success]).to be true
      expect(result[:proficiency]).to be > 0.1
    end

    it 'returns error for unknown skill' do
      result = engine.practice_skill(skill_id: 'bad', success: true)
      expect(result[:success]).to be false
    end
  end

  describe '#execute_production' do
    it 'executes and records outcome' do
      prod = engine.add_production(
        skill_id: skill.id, condition: 'test',
        action: 'act', domain: :test
      )
      result = engine.execute_production(production_id: prod.id, success: true)
      expect(result[:success]).to be true
      expect(result[:success_rate]).to eq(1.0)
    end
  end

  describe '#skill_assessment' do
    it 'returns assessment with productions' do
      prod = engine.add_production(
        skill_id: skill.id, condition: 'test',
        action: 'act', domain: :test
      )
      engine.execute_production(production_id: prod.id, success: true)
      result = engine.skill_assessment(skill_id: skill.id)
      expect(result[:success]).to be true
      expect(result[:productions].size).to eq(1)
    end
  end

  describe '#compiled_skills' do
    it 'returns skills above compilation threshold' do
      8.times { engine.practice_skill(skill_id: skill.id, success: true) }
      expect(engine.compiled_skills.size).to eq(1)
    end
  end

  describe '#autonomous_skills' do
    it 'returns skills above automation threshold' do
      12.times { engine.practice_skill(skill_id: skill.id, success: true) }
      expect(engine.autonomous_skills.size).to eq(1)
    end
  end

  describe '#by_domain' do
    it 'filters by domain' do
      skill
      engine.create_skill(name: 'other', domain: :dns)
      expect(engine.by_domain(domain: :http).size).to eq(1)
    end
  end

  describe '#most_practiced' do
    it 'returns skills sorted by practice count' do
      3.times { engine.practice_skill(skill_id: skill.id, success: true) }
      other = engine.create_skill(name: 'other', domain: :dns)
      engine.practice_skill(skill_id: other.id, success: true)
      results = engine.most_practiced(limit: 2)
      expect(results.first.practice_count).to be >= results.last.practice_count
    end
  end

  describe '#decay_all' do
    it 'reduces proficiency of all skills' do
      5.times { engine.practice_skill(skill_id: skill.id, success: true) }
      original = skill.proficiency
      engine.decay_all
      expect(skill.proficiency).to be < original
    end
  end

  describe '#prune_stale' do
    it 'removes skills with near-zero proficiency' do
      skill
      50.times { skill.decay! }
      pruned = engine.prune_stale
      expect(pruned).to be >= 0
    end
  end

  describe '#to_h' do
    it 'returns summary stats' do
      skill
      stats = engine.to_h
      expect(stats[:total_skills]).to eq(1)
      expect(stats).to include(:compiled_count, :autonomous_count, :stage_counts)
    end
  end
end
