# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module Procedural
          module Helpers
            module Constants
              MAX_SKILLS = 200
              MAX_PRODUCTIONS = 500
              MAX_HISTORY = 300

              DEFAULT_PROFICIENCY = 0.1
              PROFICIENCY_FLOOR = 0.0
              PROFICIENCY_CEILING = 1.0

              PRACTICE_GAIN = 0.08
              COMPILATION_THRESHOLD = 0.6
              AUTOMATION_THRESHOLD = 0.85
              DECAY_RATE = 0.01
              STALE_THRESHOLD = 300

              SKILL_STAGES = %i[declarative associative autonomous].freeze

              STAGE_LABELS = {
                (0.0...0.3)  => :declarative,
                (0.3...0.6)  => :associative,
                (0.6...0.85) => :compiled,
                (0.85..1.0)  => :autonomous
              }.freeze

              PROFICIENCY_LABELS = {
                (0.8..)     => :expert,
                (0.6...0.8) => :proficient,
                (0.4...0.6) => :intermediate,
                (0.2...0.4) => :beginner,
                (..0.2)     => :novice
              }.freeze
            end
          end
        end
      end
    end
  end
end
