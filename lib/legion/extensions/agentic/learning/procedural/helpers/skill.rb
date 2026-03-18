# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Learning
        module Procedural
          module Helpers
            class Skill
              include Constants

              attr_reader :id, :name, :domain, :proficiency, :practice_count,
                          :stage, :productions, :created_at, :last_practiced_at

              def initialize(name:, domain:)
                @id               = SecureRandom.uuid
                @name             = name
                @domain           = domain
                @proficiency      = DEFAULT_PROFICIENCY
                @practice_count   = 0
                @stage            = :declarative
                @productions      = []
                @created_at       = Time.now.utc
                @last_practiced_at = @created_at
              end

              def practice!(success:)
                @practice_count    += 1
                @last_practiced_at  = Time.now.utc
                gain = success ? PRACTICE_GAIN : PRACTICE_GAIN * 0.3
                @proficiency = (@proficiency + gain).clamp(PROFICIENCY_FLOOR, PROFICIENCY_CEILING)
                update_stage
              end

              def add_production(production_id)
                @productions << production_id unless @productions.include?(production_id)
              end

              def compiled?
                @proficiency >= COMPILATION_THRESHOLD
              end

              def autonomous?
                @proficiency >= AUTOMATION_THRESHOLD
              end

              def stage_label
                STAGE_LABELS.find { |range, _| range.cover?(@proficiency) }&.last || :declarative
              end

              def proficiency_label
                PROFICIENCY_LABELS.find { |range, _| range.cover?(@proficiency) }&.last || :novice
              end

              def decay!
                @proficiency = (@proficiency - DECAY_RATE).clamp(PROFICIENCY_FLOOR, PROFICIENCY_CEILING)
                update_stage
              end

              def stale?
                (Time.now.utc - @last_practiced_at) > STALE_THRESHOLD
              end

              def to_h
                {
                  id:                @id,
                  name:              @name,
                  domain:            @domain,
                  proficiency:       @proficiency,
                  proficiency_label: proficiency_label,
                  stage:             @stage,
                  stage_label:       stage_label,
                  practice_count:    @practice_count,
                  production_count:  @productions.size,
                  compiled:          compiled?,
                  autonomous:        autonomous?,
                  created_at:        @created_at,
                  last_practiced_at: @last_practiced_at
                }
              end

              private

              def update_stage
                @stage = if autonomous?
                           :autonomous
                         elsif compiled?
                           :associative
                         else
                           :declarative
                         end
              end
            end
          end
        end
      end
    end
  end
end
