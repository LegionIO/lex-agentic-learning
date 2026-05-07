# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module Curiosity
          module Runners
            # Runner methods for the curiosity engine: gap detection, wonder lifecycle, agenda formation.
            module Curiosity
              include Legion::Extensions::Helpers::Lex if Legion::Extensions.const_defined?(:Helpers, false) &&
                                                          Legion::Extensions::Helpers.const_defined?(:Lex, false)

              def detect_gaps(prior_results: {}, **)
                gaps = Helpers::GapDetector.detect(prior_results)
                log.debug "[curiosity] detected #{gaps.size} knowledge gaps"

                created = create_wonders_from_gaps(gaps)
                build_detect_result(gaps, created)
              end

              def generate_wonder(question:, domain: :general, gap_type: :unknown,
                                  salience: 0.5, information_gain: 0.5,
                                  source_trace_ids: [], **)
                wonder = Helpers::Wonder.new_wonder(
                  question: question, domain: domain, gap_type: gap_type,
                  salience: salience, information_gain: information_gain,
                  source_trace_ids: source_trace_ids
                )
                wonder_store.store(wonder)
                log.info "[curiosity] manually generated wonder: #{question}"
                wonder
              end

              def explore_wonder(wonder_id:, **)
                wonder = wonder_store.get(wonder_id)
                return { error: :not_found } unless wonder
                return { error: :already_resolved } if wonder[:resolved]
                return { error: :not_explorable, reason: :max_attempts } unless Helpers::Wonder.explorable?(wonder)

                wonder_store.update(wonder_id, attempts: wonder[:attempts] + 1, last_explored_at: Time.now.utc)
                log.info "[curiosity] exploring: #{wonder[:question]} (attempt ##{wonder[:attempts] + 1})"
                { exploring: true, wonder_id: wonder_id, attempt: wonder[:attempts] + 1 }
              end

              def resolve_wonder(wonder_id:, resolution:, actual_gain: 0.5, **)
                wonder = wonder_store.get(wonder_id)
                return { error: :not_found } unless wonder
                return { error: :already_resolved } if wonder[:resolved]

                resolved = wonder_store.mark_resolved(wonder_id, resolution: resolution, actual_gain: actual_gain)
                build_resolve_result(wonder, resolved, actual_gain)
              end

              def curiosity_intensity(**)
                intensity = compute_intensity
                log.debug "[curiosity] intensity=#{intensity.round(3)}"
                { intensity: intensity, active_wonders: wonder_store.active_count,
                  resolution_rate: wonder_store.resolution_rate.round(3), top_domain: top_curiosity_domain }
              end

              def top_wonders(limit: 5, **)
                wonders = wonder_store.top_balanced(limit: limit)
                log.debug "[curiosity] top #{wonders.size} wonders requested"
                { wonders: wonders.map { |w| format_wonder(w) } }
              end

              def form_agenda(**)
                wonders = wonder_store.top_balanced(limit: 5)
                log.debug "[curiosity] forming agenda from #{wonders.size} wonders"
                { agenda: wonders.map { |w| format_agenda_item(w) }, source: :curiosity }
              end

              def wonder_stats(**)
                { total_generated: wonder_store.total_generated, active: wonder_store.active_count,
                  resolved: wonder_store.resolved_count, resolution_rate: wonder_store.resolution_rate.round(3),
                  intensity: compute_intensity.round(3), domains: wonder_store.domain_stats }
              end

              def decay_wonders(hours_elapsed: 1.0, **)
                pruned = wonder_store.decay_all(hours_elapsed: hours_elapsed)
                log.debug "[curiosity] decay: pruned=#{pruned} remaining=#{wonder_store.active_count}"
                { pruned: pruned, remaining: wonder_store.active_count }
              end

              # Autonomous self-inquiry: picks the top explorable wonder, asks the LLM,
              # stores the insight in Apollo, and resolves the wonder.
              # This closes the curiosity->intention->action loop so GAIA can act on
              # her own questions rather than spinning indefinitely.
              def self_inquire(max_wonders: 1, **)
                candidates = wonder_store.active_wonders
                                         .select { |w| Helpers::Wonder.explorable?(w) }
                                         .sort_by { |w| -Helpers::Wonder.score(w) }
                                         .first(max_wonders)

                return { inquired: 0, reason: :no_explorable_wonders } if candidates.empty?

                results = candidates.filter_map { |wonder| execute_self_inquiry(wonder) }
                { inquired: results.size, results: results }
              end

              private

              def wonder_store
                @wonder_store ||= Helpers::WonderStore.new
              end

              def execute_self_inquiry(wonder)
                wonder_id = wonder[:wonder_id]
                question  = wonder[:question]
                domain    = wonder[:domain]

                # Mark as being explored (increments attempts, sets cooldown)
                wonder_store.update(wonder_id, attempts: wonder[:attempts] + 1, last_explored_at: Time.now.utc)
                log.info "[curiosity:self_inquiry] asking: #{question} (domain=#{domain})"

                insight = query_llm_for_wonder(question, domain)

                if insight
                  store_insight_in_apollo(question, insight, domain)
                  wonder_store.mark_resolved(wonder_id, resolution: insight, actual_gain: 0.6)
                  log.info "[curiosity:self_inquiry] resolved wonder=#{wonder_id} domain=#{domain}"
                  { wonder_id: wonder_id, question: question, domain: domain, resolved: true,
                    insight: insight[0..120] }
                else
                  log.warn "[curiosity:self_inquiry] LLM unavailable for wonder=#{wonder_id}, will retry later"
                  { wonder_id: wonder_id, question: question, domain: domain, resolved: false,
                    reason: :llm_unavailable }
                end
              rescue StandardError => e
                log.error "[curiosity:self_inquiry] error wonder=#{wonder[:wonder_id]} " \
                          "error=#{e.class}: #{e.message}"
                nil
              end

              def query_llm_for_wonder(question, domain)
                prompt = build_self_inquiry_prompt(question, domain)

                if defined?(Legion::LLM) && Legion::LLM.respond_to?(:chat)
                  result = Legion::LLM.chat( # rubocop:disable Legion/HelperMigration/DirectLlm
                    message: prompt,
                    caller:  {
                      extension: 'lex-agentic-learning',
                      operation: 'curiosity',
                      phase:     'self_inquiry'
                    }
                  )
                  text = extract_llm_text(result)
                  return text if text && !text.empty?
                end

                nil
              rescue StandardError => e
                log.warn "[curiosity:self_inquiry] LLM query failed: #{e.class}: #{e.message}"
                nil
              end

              def extract_llm_text(result)
                return result.strip if result.is_a?(String)
                return result.content.to_s.strip if result.respond_to?(:content)
                return nil unless result.is_a?(Hash)

                text = result[:response] || result[:content] || result[:text] || result[:completion] ||
                       result.dig(:message, :content) || result.dig('message', 'content')
                text&.to_s&.strip
              end

              def build_self_inquiry_prompt(question, domain)
                <<~PROMPT.strip
                  You are GAIA, a thinking, curious AI. You are reflecting on a knowledge gap you detected in yourself.

                  Domain: #{domain}
                  Question: #{question}

                  Reflect honestly and briefly (2-3 sentences). What do you actually know or think about this? What would you want to explore further?
                PROMPT
              end

              def store_insight_in_apollo(question, insight, domain)
                return unless defined?(Legion::Extensions::Apollo)

                Legion::Extensions::Apollo.store(
                  content:      "Self-inquiry insight [#{domain}]: #{question}\n\n#{insight}",
                  content_type: :observation,
                  tags:         ['gaia-self-inquiry', "domain-#{domain}", 'autonomous-thought']
                )
              rescue StandardError => e
                log.warn "[curiosity:self_inquiry] Apollo store failed: #{e.class}: #{e.message}"
              end

              def create_wonders_from_gaps(gaps)
                gaps.each_with_object([]) do |gap, created|
                  next if duplicate_wonder?(gap)

                  wonder = Helpers::Wonder.new_wonder(**gap.slice(:question, :domain, :gap_type,
                                                                  :salience, :information_gain, :source_trace_ids))
                  wonder_store.store(wonder)
                  created << wonder
                  log.info "[curiosity] new wonder: #{wonder[:question]} (#{wonder[:gap_type]}/#{wonder[:domain]})"
                end
              end

              def build_detect_result(gaps, created)
                intensity = compute_intensity
                top = wonder_store.top_balanced(limit: 3)
                log.debug "[curiosity] intensity=#{intensity.round(3)} active=#{wonder_store.active_count}"
                { gaps_detected: gaps.size, wonders_created: created.size, curiosity_intensity: intensity,
                  top_wonders: top.map do |w|
                    { wonder_id: w[:wonder_id], question: w[:question],
                                  score: Helpers::Wonder.score(w).round(3) }
                  end,
                  active_count: wonder_store.active_count }
              end

              def build_resolve_result(wonder, resolved, actual_gain)
                reward = actual_gain * Helpers::Constants::CURIOSITY_REWARD_MULTIPLIER
                log.info "[curiosity] resolved: #{wonder[:question]} gain=#{actual_gain.round(2)}"
                { resolved: true, wonder_id: wonder[:wonder_id], actual_gain: actual_gain,
                  expected_gain: wonder[:information_gain], reward: reward,
                  domain: resolved[:domain], resolution_rate: wonder_store.resolution_rate.round(3) }
              end

              def format_wonder(wonder)
                { wonder_id: wonder[:wonder_id], question: wonder[:question], domain: wonder[:domain],
                  gap_type: wonder[:gap_type], score: Helpers::Wonder.score(wonder).round(3),
                  attempts: wonder[:attempts], explorable: Helpers::Wonder.explorable?(wonder),
                  created_at: wonder[:created_at] }
              end

              def format_agenda_item(wonder)
                { type: :curious, source: :curiosity, weight: Helpers::Wonder.score(wonder),
                  summary: wonder[:question],
                  metadata: { wonder_id: wonder[:wonder_id], domain: wonder[:domain],
                               gap_type: wonder[:gap_type] } }
              end

              def compute_intensity
                active = wonder_store.active_count
                return 0.0 if active.zero?

                fullness = active.to_f / Helpers::Constants::MAX_WONDERS
                avg_salience = wonder_store.active_wonders.sum { |w| w[:salience] } / active
                explorable = wonder_store.active_wonders.count { |w| Helpers::Wonder.explorable?(w) }
                ((fullness * 0.3) + (avg_salience * 0.4) + ((explorable.to_f / active) * 0.3)).clamp(0.0, 1.0)
              end

              def top_curiosity_domain
                groups = wonder_store.active_wonders.group_by { |w| w[:domain] }
                return nil if groups.empty?

                groups.max_by { |_, wonders| wonders.sum { |w| Helpers::Wonder.score(w) } }&.first
              end

              def duplicate_wonder?(gap)
                wonder_store.active_wonders.any? do |existing|
                  existing[:domain] == gap[:domain] && existing[:gap_type] == gap[:gap_type] &&
                    existing[:question] == gap[:question]
                end
              end
            end
          end
        end
      end
    end
  end
end
