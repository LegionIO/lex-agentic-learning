# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module PreferenceLearning
          module Helpers
            class PreferenceEngine
              def initialize
                @options      = {} # id => Option
                @comparisons  = 0
              end

              def register_option(label:, domain: :general)
                return { error: 'max options reached' } if @options.size >= Constants::MAX_OPTIONS

                option = Option.new(label: label, domain: domain)
                @options[option.id] = option
                option.to_h
              end

              def record_comparison(winner_id:, loser_id:)
                winner = @options[winner_id]
                loser  = @options[loser_id]
                return { error: 'option not found' } unless winner && loser

                @comparisons += 1
                winner.win!
                loser.lose!

                {
                  winner_id:    winner_id,
                  loser_id:     loser_id,
                  comparisons:  @comparisons,
                  winner_score: winner.preference_score,
                  loser_score:  loser.preference_score
                }
              end

              def predict_preference(option_a_id:, option_b_id:)
                a = @options[option_a_id]
                b = @options[option_b_id]
                return { error: 'option not found' } unless a && b

                diff       = (a.preference_score - b.preference_score).abs
                confidence = diff.clamp(0.0, 1.0)
                preferred  = a.preference_score >= b.preference_score ? a : b

                {
                  preferred_id:    preferred.id,
                  preferred_label: preferred.label,
                  confidence:      confidence,
                  score_a:         a.preference_score,
                  score_b:         b.preference_score
                }
              end

              def top_preferences(domain: nil, limit: 5)
                filtered(domain).sort_by { |o| -o.preference_score }.first(limit).map(&:to_h)
              end

              def bottom_preferences(domain: nil, limit: 5)
                filtered(domain).sort_by(&:preference_score).first(limit).map(&:to_h)
              end

              def preferences_by_domain(domain:)
                @options.values
                        .select { |o| o.domain == domain }
                        .sort_by { |o| -o.preference_score }
                        .map(&:to_h)
              end

              def preference_stability
                scores = @options.values.map(&:preference_score)
                return 0.0 if scores.size < 2

                mean = scores.sum / scores.size.to_f
                variance = scores.sum { |s| (s - mean)**2 } / scores.size.to_f
                Math.sqrt(variance)
              end

              def most_compared(limit: 10)
                @options.values
                        .sort_by { |o| -o.times_seen }
                        .first(limit)
                        .map(&:to_h)
              end

              def decay_all
                @options.each_value do |option|
                  delta = (option.preference_score - Constants::DEFAULT_PREFERENCE) * Constants::DECAY_RATE
                  option.preference_score = (option.preference_score - delta)
                                            .clamp(Constants::PREFERENCE_FLOOR, Constants::PREFERENCE_CEILING)
                end
                @options.size
              end

              def to_h
                {
                  total_options: @options.size,
                  comparisons:   @comparisons,
                  stability:     preference_stability,
                  options:       @options.values.map(&:to_h)
                }
              end

              private

              def filtered(domain)
                return @options.values if domain.nil?

                @options.values.select { |o| o.domain == domain }
              end
            end
          end
        end
      end
    end
  end
end
