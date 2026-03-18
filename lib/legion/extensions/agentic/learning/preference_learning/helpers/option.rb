# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Learning
        module PreferenceLearning
          module Helpers
            class Option
              attr_reader :id, :label, :domain, :created_at
              attr_accessor :preference_score, :wins, :losses, :times_seen

              def initialize(label:, domain: :general)
                @id               = SecureRandom.uuid
                @label            = label
                @domain           = domain
                @preference_score = Constants::DEFAULT_PREFERENCE
                @wins             = 0
                @losses           = 0
                @times_seen       = 0
                @created_at       = Time.now.utc
              end

              def win!
                @wins         += 1
                @times_seen   += 1
                @preference_score = clamp(@preference_score + Constants::WIN_BOOST)
              end

              def lose!
                @losses       += 1
                @times_seen   += 1
                @preference_score = clamp(@preference_score - Constants::LOSS_PENALTY)
              end

              def win_rate
                total = @wins + @losses
                return 0.0 if total.zero?

                @wins.to_f / (total + 1)
              end

              def preference_label
                Constants::PREFERENCE_LABELS.each do |range, label|
                  return label if range.cover?(@preference_score)
                end
                :neutral
              end

              def to_h
                {
                  id:               @id,
                  label:            @label,
                  domain:           @domain,
                  preference_score: @preference_score,
                  wins:             @wins,
                  losses:           @losses,
                  times_seen:       @times_seen,
                  win_rate:         win_rate,
                  preference_label: preference_label,
                  created_at:       @created_at
                }
              end

              private

              def clamp(value)
                value.clamp(Constants::PREFERENCE_FLOOR, Constants::PREFERENCE_CEILING)
              end
            end
          end
        end
      end
    end
  end
end
