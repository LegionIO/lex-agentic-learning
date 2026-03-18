# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module Procedural
          module Helpers
            class LearningEngine
              include Constants

              attr_reader :history

              def initialize
                @skills      = {}
                @productions = {}
                @history     = []
              end

              def create_skill(name:, domain:)
                evict_oldest_skill if @skills.size >= MAX_SKILLS

                skill = Skill.new(name: name, domain: domain)
                @skills[skill.id] = skill
                record_history(:skill_created, skill.id)
                skill
              end

              def add_production(skill_id:, condition:, action:, domain:)
                skill = @skills[skill_id]
                return { success: false, reason: :skill_not_found } unless skill
                return { success: false, reason: :max_productions } if @productions.size >= MAX_PRODUCTIONS

                production = Production.new(
                  condition: condition, action: action,
                  domain: domain, skill_id: skill_id
                )
                @productions[production.id] = production
                skill.add_production(production.id)
                record_history(:production_added, production.id)
                production
              end

              def practice_skill(skill_id:, success:)
                skill = @skills[skill_id]
                return { success: false, reason: :not_found } unless skill

                skill.practice!(success: success)
                record_history(:practiced, skill_id)
                build_practice_result(skill)
              end

              def execute_production(production_id:, success:)
                production = @productions[production_id]
                return { success: false, reason: :not_found } unless production

                production.execute!(success: success)
                record_history(:production_executed, production_id)
                { success: true, production_id: production_id, success_rate: production.success_rate }
              end

              def skill_assessment(skill_id:)
                skill = @skills[skill_id]
                return { success: false, reason: :not_found } unless skill

                productions = skill.productions.filter_map { |pid| @productions[pid] }
                build_assessment(skill, productions)
              end

              def compiled_skills
                @skills.values.select(&:compiled?)
              end

              def autonomous_skills
                @skills.values.select(&:autonomous?)
              end

              def by_domain(domain:)
                @skills.values.select { |s| s.domain == domain }
              end

              def most_practiced(limit: 5)
                @skills.values.sort_by { |s| -s.practice_count }.first(limit)
              end

              def decay_all
                @skills.each_value(&:decay!)
              end

              def prune_stale
                stale_ids = @skills.select { |_id, s| s.proficiency <= 0.02 }.keys
                stale_ids.each do |sid|
                  remove_skill_productions(sid)
                  @skills.delete(sid)
                end
                stale_ids.size
              end

              def to_h
                {
                  total_skills:      @skills.size,
                  total_productions: @productions.size,
                  compiled_count:    compiled_skills.size,
                  autonomous_count:  autonomous_skills.size,
                  history_count:     @history.size,
                  stage_counts:      stage_counts
                }
              end

              private

              def build_practice_result(skill)
                {
                  success:     true,
                  skill_id:    skill.id,
                  proficiency: skill.proficiency,
                  stage:       skill.stage,
                  stage_label: skill.stage_label
                }
              end

              def build_assessment(skill, productions)
                {
                  success:          true,
                  skill:            skill.to_h,
                  productions:      productions.map(&:to_h),
                  reliable_count:   productions.count(&:reliable?),
                  total_executions: productions.sum(&:execution_count)
                }
              end

              def remove_skill_productions(skill_id)
                @productions.delete_if { |_id, prod| prod.skill_id == skill_id }
              end

              def evict_oldest_skill
                oldest_id = @skills.min_by { |_id, s| s.last_practiced_at }&.first
                return unless oldest_id

                remove_skill_productions(oldest_id)
                @skills.delete(oldest_id)
              end

              def record_history(event, subject_id)
                @history << { event: event, subject_id: subject_id, at: Time.now.utc }
                @history.shift while @history.size > MAX_HISTORY
              end

              def stage_counts
                @skills.values.each_with_object(Hash.new(0)) do |skill, counts|
                  counts[skill.stage] += 1
                end
              end
            end
          end
        end
      end
    end
  end
end
