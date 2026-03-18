# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module Fermentation
          module Helpers
            module Constants
              MAX_SUBSTRATES = 500
              MAX_BATCHES = 50

              DEFAULT_POTENCY = 0.3
              MATURATION_RATE = 0.05
              VOLATILITY_DECAY = 0.02
              CATALYSIS_BOOST = 0.12
              SPOILAGE_THRESHOLD = 0.1
              RIPE_THRESHOLD = 0.7
              PEAK_THRESHOLD = 0.9
              OVER_FERMENTED_DECAY = 0.03

              SUBSTRATE_TYPES = %i[
                raw_idea unresolved_problem partial_pattern
                dormant_association vague_intuition half_formed_belief
                contradictory_evidence lingering_question
              ].freeze

              FERMENTATION_STAGES = %i[
                inoculation primary_fermentation secondary_fermentation
                conditioning maturation aging peak over_fermented
              ].freeze

              CATALYST_TYPES = %i[
                analogy contrast juxtaposition
                emotional_charge sleep dream_residue
                environmental_stimulus social_interaction
              ].freeze

              DOMAINS = %i[
                cognitive emotional procedural semantic
                episodic social creative analytical
              ].freeze

              POTENCY_LABELS = {
                (0.8..)     => :transcendent,
                (0.6...0.8) => :potent,
                (0.4...0.6) => :developing,
                (0.2...0.4) => :mild,
                (..0.2)     => :inert
              }.freeze

              MATURITY_LABELS = {
                (0.8..)     => :peak,
                (0.6...0.8) => :mature,
                (0.4...0.6) => :developing,
                (0.2...0.4) => :young,
                (..0.2)     => :raw
              }.freeze

              VOLATILITY_LABELS = {
                (0.8..)     => :explosive,
                (0.6...0.8) => :volatile,
                (0.4...0.6) => :active,
                (0.2...0.4) => :stable,
                (..0.2)     => :dormant
              }.freeze

              def self.label_for(labels, value)
                labels.each { |range, label| return label if range.cover?(value) }
                :unknown
              end
            end
          end
        end
      end
    end
  end
end
