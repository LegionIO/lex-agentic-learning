# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module OutcomeListener
          module Runners
            module OutcomeListener
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex, false)

              def process_outcome(payload = {}, **)
                runner_class_name = payload[:runner_class].to_s
                status = payload[:status].to_s
                domain = Helpers::DomainExtractor.extract(runner_class_name)
                success = status == Helpers::Constants::COMPLETED_STATUS
                source_agent = payload[:source_agent] || payload[:agent_id]

                updates = {}
                updates[:meta_learning] = update_meta_learning_model(domain, success)
                updates[:learning_rate] = update_learning_rate_model(domain, success)
                updates[:scaffolding] = update_scaffolding_model(domain, success, payload)

                if write_to_apollo?
                  lesson = Helpers::LessonBuilder.build(
                    runner_class: runner_class_name,
                    function:     payload[:function],
                    status:       status,
                    domain:       domain,
                    success:      success,
                    source_agent: source_agent
                  )
                  write_apollo_lesson(lesson, source_agent) if lesson[:confidence] >= min_lesson_severity
                  updates[:lesson] = lesson
                end

                log.debug "[outcome_listener] domain=#{domain} success=#{success} updates=#{updates.keys}"
                { success: true, domain: domain, outcome: success, updates: updates }
              end

              private

              def update_meta_learning_model(domain, success)
                meta = self.class.meta_client
                domain_id = resolve_domain_id(meta, domain)
                meta.record_learning_episode(domain_id: domain_id, success: success)
              rescue StandardError => e
                log.warn "[outcome_listener] meta_learning update failed: #{e.message}"
                { error: e.message }
              end

              def update_learning_rate_model(domain, success)
                lr = self.class.learning_rate_client
                lr.record_prediction(correct: success, domain: domain.to_sym)
              rescue StandardError => e
                log.warn "[outcome_listener] learning_rate update failed: #{e.message}"
                { error: e.message }
              end

              def update_scaffolding_model(domain, success, payload)
                sc = self.class.scaffolding_client
                scaffolds = sc.engine.by_domain(domain: domain)
                return { skipped: true, reason: :no_scaffold } if scaffolds.empty?

                scaffold = scaffolds.first
                difficulty = payload[:complexity]&.to_f || Helpers::Constants::DEFAULT_DIFFICULTY
                sc.attempt_scaffolded_task(scaffold_id: scaffold.id, difficulty: difficulty, success: success)
              rescue StandardError => e
                log.warn "[outcome_listener] scaffolding update failed: #{e.message}"
                { error: e.message }
              end

              def resolve_domain_id(meta, domain)
                map = self.class.domain_map
                return map[domain] if map.key?(domain)

                result = meta.create_learning_domain(name: domain)
                map[domain] = result[:id]
                result[:id]
              end

              def write_apollo_lesson(lesson, source_agent)
                return unless defined?(Legion::Apollo)

                ingest_knowledge(content:          json_generate(lesson),
                                 content_type:     'task_outcome_lesson',
                                 tags:             ['task_outcome', lesson[:domain]],
                                 source_agent:     source_agent,
                                 knowledge_domain: 'learning')
              rescue StandardError => e
                log.warn "[outcome_listener] apollo write failed: #{e.message}"
              end

              def write_to_apollo?
                return false unless defined?(Legion::Settings)

                Legion::Settings.dig(:agentic, :learning, :write_to_apollo) != false
              rescue StandardError => e
                log.warn "[outcome_listener] write_to_apollo? check failed: #{e.message}"
                true
              end

              def min_lesson_severity
                return Helpers::Constants::DEFAULT_MIN_LESSON_SEVERITY unless defined?(Legion::Settings)

                Legion::Settings.dig(:agentic, :learning, :min_lesson_severity) ||
                  Helpers::Constants::DEFAULT_MIN_LESSON_SEVERITY
              rescue StandardError => e
                log.warn "[outcome_listener] min_lesson_severity check failed: #{e.message}"
                Helpers::Constants::DEFAULT_MIN_LESSON_SEVERITY
              end
            end
          end
        end
      end
    end
  end
end
