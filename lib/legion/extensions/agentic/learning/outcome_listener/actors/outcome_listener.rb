# frozen_string_literal: true

return unless defined?(Legion::Extensions::Actors::Subscription)

module Legion
  module Extensions
    module Agentic
      module Learning
        module OutcomeListener
          module Actor
            class OutcomeListener < Legion::Extensions::Actors::Subscription
              def runner_class
                Legion::Extensions::Agentic::Learning::OutcomeListener::Runners::OutcomeListener
              end

              def runner_function
                'process_outcome'
              end

              def check_subtask?
                false
              end

              def generate_task?
                false
              end

              def use_runner?
                false
              end

              def enabled? # rubocop:disable Legion/Extension/ActorEnabledSideEffects
                outcome_listener_setting? &&
                  defined?(Legion::Extensions::Agentic::Learning::OutcomeListener::Runners::OutcomeListener) &&
                  transport_connected?
              rescue StandardError => e
                log.warn "[outcome_listener] enabled? check failed: #{e.message}"
                false
              end

              private

              def outcome_listener_setting?
                return true unless defined?(Legion::Settings)

                Legion::Settings.dig(:agentic, :learning, :outcome_listener) != false
              rescue StandardError => e
                log.warn "[outcome_listener] settings check failed: #{e.message}"
                true
              end
            end
          end
        end
      end
    end
  end
end
