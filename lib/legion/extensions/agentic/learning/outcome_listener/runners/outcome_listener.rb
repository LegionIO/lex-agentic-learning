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

              def process_outcome(payload = {}, **options)
                payload = payload.merge(options)
                status = payload[:status].to_s
                unless [Helpers::Constants::COMPLETED_STATUS, Helpers::Constants::FAILED_STATUS,
                        Helpers::Constants::EXCEPTION_STATUS].include?(status)
                  return { success: false, skipped: true, reason: :unrecognized_status, outcome: nil }
                end
                if payload[:runner_class].to_s.strip.empty? || payload[:function].to_s.strip.empty?
                  return { success: false, skipped: true, reason: :missing_task_context, outcome: nil }
                end

                owner = Legion::Extensions::Agentic::Learning::OutcomeListener::Client
                owner.outcome_mutex.synchronize do
                  process_unique_outcome(payload, owner)
                end
              end

              private

              def process_unique_outcome(payload, owner)
                message_id = payload[:message_id]
                key = [payload[:source_agent] || payload[:agent_id], message_id]
                tracked = !message_id.to_s.strip.empty?
                return owner.processed_outcomes[key].merge(skipped: true, reason: :duplicate_outcome) if tracked && owner.processed_outcomes.key?(key)

                result = process_task_outcome(payload)
                if tracked
                  owner.processed_outcomes[key] = result
                  owner.processed_outcomes.shift while owner.processed_outcomes.size > Helpers::Constants::MAX_OUTCOME_HISTORY
                end
                result
              end

              def process_task_outcome(payload)
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
                { success: updates.values.none? { |update| update.key?(:error) },
                  domain: domain, outcome: success, evidence: :technical_execution, updates: updates }
              end

              def update_meta_learning_model(domain, success)
                meta = Legion::Extensions::Agentic::Learning::OutcomeListener::Client.meta_client
                domain_id = resolve_domain_id(meta, domain)
                meta.record_learning_episode(domain_id: domain_id, success: success)
              rescue StandardError => e
                log.warn "[outcome_listener] meta_learning update failed: #{e.message}"
                { error: e.message }
              end

              def update_learning_rate_model(domain, success)
                lr = Legion::Extensions::Agentic::Learning::OutcomeListener::Client.learning_rate_client
                lr.record_prediction(correct: success, domain: domain.to_sym)
              rescue StandardError => e
                log.warn "[outcome_listener] learning_rate update failed: #{e.message}"
                { error: e.message }
              end

              def update_scaffolding_model(domain, success, payload)
                sc = Legion::Extensions::Agentic::Learning::OutcomeListener::Client.scaffolding_client
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
                map = Legion::Extensions::Agentic::Learning::OutcomeListener::Client.domain_map
                return map[domain] if map.key?(domain)

                result = meta.create_learning_domain(name: domain)
                map[domain] = result[:id]
                result[:id]
              end

              def write_apollo_lesson(lesson, source_agent)
                return unless defined?(Legion::Apollo)

                Legion::Apollo.ingest( # rubocop:disable Legion/HelperMigration/DirectKnowledge
                  content:               json_generate(lesson),
                  tags:                  ['task_outcome', lesson[:domain]].compact,
                  source_agent:          source_agent,
                  access_scope:          'private',
                  content_type:          'task_outcome_lesson',
                  knowledge_domain:      'learning',
                  identity_principal_id: nil
                )
              rescue StandardError => e
                log.warn "[outcome_listener] apollo write failed: #{e.message}"
              end

              def write_to_apollo?
                return false unless defined?(Legion::Settings)

                Legion::Settings.dig(:agentic, :learning, :write_to_apollo) != false
              rescue StandardError => e
                log.warn "[outcome_listener] write_to_apollo? check failed: #{e.message}"
                false
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
