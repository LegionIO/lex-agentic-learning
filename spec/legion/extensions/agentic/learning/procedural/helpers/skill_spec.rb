# frozen_string_literal: true

RSpec.describe Legion::Extensions::Agentic::Learning::Procedural::Helpers::Skill do
  subject(:skill) { described_class.new(name: 'api_retry', domain: :http) }

  describe '#initialize' do
    it 'assigns a UUID' do
      expect(skill.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'starts at declarative stage' do
      expect(skill.stage).to eq(:declarative)
    end

    it 'starts with low proficiency' do
      expect(skill.proficiency).to be < 0.2
    end
  end

  describe '#practice!' do
    it 'increases proficiency on success' do
      original = skill.proficiency
      skill.practice!(success: true)
      expect(skill.proficiency).to be > original
    end

    it 'increases proficiency less on failure' do
      success_skill = described_class.new(name: 'test', domain: :test)
      failure_skill = described_class.new(name: 'test', domain: :test)
      success_skill.practice!(success: true)
      failure_skill.practice!(success: false)
      expect(success_skill.proficiency).to be > failure_skill.proficiency
    end

    it 'transitions stage with practice' do
      10.times { skill.practice!(success: true) }
      expect(skill.stage).not_to eq(:declarative)
    end
  end

  describe '#compiled?' do
    it 'returns false initially' do
      expect(skill).not_to be_compiled
    end

    it 'returns true after sufficient practice' do
      8.times { skill.practice!(success: true) }
      expect(skill).to be_compiled
    end
  end

  describe '#autonomous?' do
    it 'returns false initially' do
      expect(skill).not_to be_autonomous
    end

    it 'returns true after extensive practice' do
      12.times { skill.practice!(success: true) }
      expect(skill).to be_autonomous
    end
  end

  describe '#stage_label' do
    it 'returns a label symbol' do
      expect(skill.stage_label).to be_a(Symbol)
    end
  end

  describe '#proficiency_label' do
    it 'returns a label symbol' do
      expect(skill.proficiency_label).to be_a(Symbol)
    end
  end

  describe '#decay!' do
    it 'reduces proficiency' do
      5.times { skill.practice!(success: true) }
      original = skill.proficiency
      skill.decay!
      expect(skill.proficiency).to be < original
    end
  end

  describe '#add_production' do
    it 'adds production id' do
      skill.add_production('prod-123')
      expect(skill.productions).to include('prod-123')
    end

    it 'does not add duplicates' do
      2.times { skill.add_production('prod-123') }
      expect(skill.productions.size).to eq(1)
    end
  end

  describe '#to_h' do
    it 'returns hash representation' do
      hash = skill.to_h
      expect(hash).to include(:id, :name, :domain, :proficiency, :stage, :compiled, :autonomous)
    end
  end
end
