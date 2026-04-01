# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module OutcomeListener
          module Helpers
            module LessonBuilder
              include Constants

              module_function

              def build(runner_class:, domain:, success:, status: nil, function: nil, source_agent: nil) # rubocop:disable Lint/UnusedMethodArgument
                {
                  situation:    build_situation(runner_class, function),
                  outcome:      success ? :success : :failure,
                  lesson:       build_lesson(domain, success),
                  domain:       domain,
                  confidence:   success ? DEFAULT_CONFIDENCE_SUCCESS : DEFAULT_CONFIDENCE_FAILURE,
                  source_agent: source_agent,
                  recorded_at:  Time.now.utc
                }
              end

              def build_situation(runner_class, function)
                parts = [runner_class.to_s]
                parts << "##{function}" if function
                parts.join
              end

              def build_lesson(domain, success)
                if success
                  "Task in domain '#{domain}' completed successfully"
                else
                  "Task in domain '#{domain}' failed — review for corrective action"
                end
              end
            end
          end
        end
      end
    end
  end
end
