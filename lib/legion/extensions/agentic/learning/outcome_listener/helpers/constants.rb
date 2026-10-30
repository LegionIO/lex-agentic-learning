# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module OutcomeListener
          module Helpers
            module Constants
              DEFAULT_MIN_LESSON_SEVERITY = 0.3
              COMPLETED_STATUS = 'task.completed'
              FAILED_STATUS = 'task.failed'
              EXCEPTION_STATUS = 'task.exception'
              MAX_OUTCOME_HISTORY = 1000
              DEFAULT_DIFFICULTY = 0.5
              DEFAULT_CONFIDENCE_SUCCESS = 0.7
              DEFAULT_CONFIDENCE_FAILURE = 0.5
            end
          end
        end
      end
    end
  end
end
