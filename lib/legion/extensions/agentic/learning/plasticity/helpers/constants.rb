# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module Plasticity
          module Helpers
            module Constants
              MAX_PATHWAYS = 300
              MAX_EVENTS = 500

              DEFAULT_LEARNING_RATE = 0.5
              STRENGTHENING_RATE = 0.08
              PRUNING_THRESHOLD = 0.15
              CRITICAL_PERIOD_MULTIPLIER = 2.5
              MATURATION_RATE = 0.01

              PLASTICITY_LABELS = {
                (0.8..)     => :highly_plastic,
                (0.6...0.8) => :plastic,
                (0.4...0.6) => :moderate,
                (0.2...0.4) => :rigid,
                (..0.2)     => :crystallized
              }.freeze

              STRENGTH_LABELS = {
                (0.8..)     => :robust,
                (0.6...0.8) => :strong,
                (0.4...0.6) => :moderate,
                (0.2...0.4) => :weak,
                (..0.2)     => :nascent
              }.freeze

              PATHWAY_TYPES = %i[
                synaptic structural functional
                homeostatic metaplastic
              ].freeze
            end
          end
        end
      end
    end
  end
end
