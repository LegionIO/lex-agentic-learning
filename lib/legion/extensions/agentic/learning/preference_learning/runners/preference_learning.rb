# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module PreferenceLearning
          module Runners
            module PreferenceLearning
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex, false)

              def register_preference_option(label:, domain: :general, **)
                result = preference_engine.register_option(label: label, domain: domain)
                if result[:error]
                  log.warn "[preference_learning] register failed: #{result[:error]}"
                else
                  log.debug "[preference_learning] registered option id=#{result[:id]} label=#{label} domain=#{domain}"
                end
                result
              end

              def record_preference_comparison(winner_id:, loser_id:, **)
                result = preference_engine.record_comparison(winner_id: winner_id, loser_id: loser_id)
                if result[:error]
                  log.warn "[preference_learning] comparison failed: #{result[:error]}"
                else
                  log.info "[preference_learning] comparison: winner=#{winner_id} loser=#{loser_id} total=#{result[:comparisons]}"
                end
                result
              end

              def predict_preference_outcome(option_a_id:, option_b_id:, **)
                result = preference_engine.predict_preference(option_a_id: option_a_id, option_b_id: option_b_id)
                if result[:error]
                  log.warn "[preference_learning] predict failed: #{result[:error]}"
                else
                  log.debug "[preference_learning] predict: preferred=#{result[:preferred_label]} confidence=#{result[:confidence].round(2)}"
                end
                result
              end

              def top_preferences_report(domain: nil, limit: 5, **)
                options = preference_engine.top_preferences(domain: domain, limit: limit)
                log.debug "[preference_learning] top #{limit} preferences domain=#{domain.inspect} count=#{options.size}"
                { domain: domain, limit: limit, options: options }
              end

              def preference_stability_report(**)
                stability = preference_engine.preference_stability
                label     = stability < 0.1 ? :stable : :variable
                log.debug "[preference_learning] stability=#{stability.round(4)} label=#{label}"
                { stability: stability, label: label }
              end

              def update_preference_learning(**)
                count = preference_engine.decay_all
                log.debug "[preference_learning] decay cycle: options_updated=#{count}"
                { decayed: count }
              end

              def preference_learning_stats(**)
                engine_hash = preference_engine.to_h
                log.debug "[preference_learning] stats: total_options=#{engine_hash[:total_options]} comparisons=#{engine_hash[:comparisons]}"
                engine_hash.merge(stability_label: preference_engine_stability_label)
              end

              private

              def preference_engine
                @preference_engine ||= Helpers::PreferenceEngine.new
              end

              def preference_engine_stability_label
                stability = preference_engine.preference_stability
                stability < 0.1 ? :stable : :variable
              end
            end
          end
        end
      end
    end
  end
end
