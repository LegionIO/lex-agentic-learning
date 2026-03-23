# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module Procedural
          module Runners
            module ProceduralLearning
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex)

              def create_skill(name:, domain:, **)
                skill = engine.create_skill(name: name, domain: domain)
                log.debug "[procedural_learning] created skill=#{name} " \
                          "domain=#{domain} id=#{skill.id[0..7]}"
                { success: true, skill_id: skill.id, name: name, domain: domain,
                  proficiency: skill.proficiency, stage: skill.stage }
              end

              def add_skill_production(skill_id:, condition:, action:, domain:, **)
                result = engine.add_production(
                  skill_id: skill_id, condition: condition,
                  action: action, domain: domain
                )

                return result unless result.is_a?(Helpers::Production)

                log.debug '[procedural_learning] production added ' \
                          "skill=#{skill_id[0..7]} condition=#{condition}"
                { success: true, production_id: result.id, skill_id: skill_id }
              end

              def practice_skill(skill_id:, success:, **)
                result = engine.practice_skill(skill_id: skill_id, success: success)
                log.debug "[procedural_learning] practice skill=#{skill_id[0..7]} " \
                          "success=#{success} proficiency=#{result[:proficiency]&.round(3)}"
                result
              end

              def execute_production(production_id:, success:, **)
                result = engine.execute_production(production_id: production_id, success: success)
                log.debug "[procedural_learning] execute production=#{production_id[0..7]} " \
                          "success=#{success}"
                result
              end

              def skill_assessment(skill_id:, **)
                result = engine.skill_assessment(skill_id: skill_id)
                log.debug "[procedural_learning] assessment skill=#{skill_id[0..7]}"
                result
              end

              def compiled_skills(**)
                skills = engine.compiled_skills
                log.debug "[procedural_learning] compiled count=#{skills.size}"
                { success: true, skills: skills.map(&:to_h), count: skills.size }
              end

              def autonomous_skills(**)
                skills = engine.autonomous_skills
                log.debug "[procedural_learning] autonomous count=#{skills.size}"
                { success: true, skills: skills.map(&:to_h), count: skills.size }
              end

              def most_practiced_skills(limit: 5, **)
                skills = engine.most_practiced(limit: limit)
                log.debug "[procedural_learning] most_practiced limit=#{limit}"
                { success: true, skills: skills.map(&:to_h), count: skills.size }
              end

              def update_procedural_learning(**)
                engine.decay_all
                pruned = engine.prune_stale
                log.debug "[procedural_learning] decay+prune pruned=#{pruned}"
                { success: true, pruned: pruned }
              end

              def procedural_learning_stats(**)
                stats = engine.to_h
                log.debug "[procedural_learning] stats total=#{stats[:total_skills]}"
                { success: true }.merge(stats)
              end

              private

              def engine
                @engine ||= Helpers::LearningEngine.new
              end
            end
          end
        end
      end
    end
  end
end
