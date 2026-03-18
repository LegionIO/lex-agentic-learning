# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module PreferenceLearning
          module Helpers
            module Constants
              PREFERENCE_LABELS = {
                (0.8..)     => :strongly_preferred,
                (0.6...0.8) => :preferred,
                (0.4...0.6) => :neutral,
                (0.2...0.4) => :disliked,
                (..0.2)     => :strongly_disliked
              }.freeze

              MAX_OPTIONS     = 200
              MAX_COMPARISONS = 1000
              MAX_HISTORY     = 500

              DEFAULT_PREFERENCE  = 0.5
              PREFERENCE_FLOOR    = 0.0
              PREFERENCE_CEILING  = 1.0

              WIN_BOOST     = 0.08
              LOSS_PENALTY  = 0.06
              DECAY_RATE    = 0.01
            end
          end
        end
      end
    end
  end
end
