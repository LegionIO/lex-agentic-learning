# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module Fermentation
          module Helpers
            class FermentationEngine
              include Constants

              def initialize
                @substrates = {}
                @batches    = {}
              end

              def create_substrate(substrate_type:, domain:, content: '', potency: nil, volatility: nil)
                return nil unless SUBSTRATE_TYPES.include?(substrate_type.to_sym)

                sub = Substrate.new(substrate_type: substrate_type, domain: domain, content: content,
                                    potency: potency, volatility: volatility)
                @substrates[sub.id] = sub
                batch = find_or_create_batch(domain: domain)
                batch.add_substrate(sub)
                prune_substrates
                sub
              end

              def ferment(substrate_id:, rate: MATURATION_RATE)
                sub = @substrates[substrate_id]
                return nil unless sub

                sub.ferment!(rate)
                sub
              end

              def catalyze(substrate_id:, catalyst_type:)
                return nil unless CATALYST_TYPES.include?(catalyst_type.to_sym)

                sub = @substrates[substrate_id]
                return nil unless sub

                sub.catalyze!(catalyst_type)
                sub
              end

              def ferment_all!(rate: MATURATION_RATE)
                @batches.each_value { |b| b.ferment_all!(rate) }
              end

              def substrates_by_domain(domain:) = @substrates.values.select { |s| s.domain == domain.to_sym }
              def substrates_by_type(type:) = @substrates.values.select { |s| s.substrate_type == type.to_sym }
              def substrates_by_stage(stage:) = @substrates.values.select { |s| s.stage == stage.to_sym }
              def ripe_substrates = @substrates.values.select(&:ripe?)
              def peak_substrates = @substrates.values.select(&:peak?)
              def spoiled_substrates = @substrates.values.select(&:spoiled?)
              def raw_substrates = @substrates.values.select(&:raw?)

              def most_potent(limit: 5)
                @substrates.values.sort_by { |s| -s.potency }.first(limit)
              end

              def most_mature(limit: 5)
                @substrates.values.sort_by { |s| -s.maturity }.first(limit)
              end

              def overall_potency
                return 0.0 if @substrates.empty?

                (@substrates.values.sum(&:potency) / @substrates.size).round(10)
              end

              def overall_maturity
                return 0.0 if @substrates.empty?

                (@substrates.values.sum(&:maturity) / @substrates.size).round(10)
              end

              def overall_volatility
                return 0.0 if @substrates.empty?

                (@substrates.values.sum(&:volatility) / @substrates.size).round(10)
              end

              def yield_rate
                return 0.0 if @substrates.empty?

                (ripe_substrates.size.to_f / @substrates.size).round(10)
              end

              def stage_distribution
                dist = Hash.new(0)
                @substrates.each_value { |s| dist[s.stage] += 1 }
                dist
              end

              def fermentation_report
                {
                  total_substrates:   @substrates.size,
                  total_batches:      @batches.size,
                  overall_potency:    overall_potency,
                  potency_label:      Constants.label_for(POTENCY_LABELS, overall_potency),
                  overall_maturity:   overall_maturity,
                  maturity_label:     Constants.label_for(MATURITY_LABELS, overall_maturity),
                  overall_volatility: overall_volatility,
                  volatility_label:   Constants.label_for(VOLATILITY_LABELS, overall_volatility),
                  yield_rate:         yield_rate,
                  ripe_count:         ripe_substrates.size,
                  peak_count:         peak_substrates.size,
                  spoiled_count:      spoiled_substrates.size,
                  stage_distribution: stage_distribution,
                  batches:            @batches.values.map(&:to_h),
                  most_potent:        most_potent(limit: 3).map(&:to_h)
                }
              end

              def to_h
                {
                  total_substrates: @substrates.size,
                  total_batches:    @batches.size,
                  potency:          overall_potency,
                  maturity:         overall_maturity,
                  volatility:       overall_volatility
                }
              end

              private

              def find_or_create_batch(domain:)
                key = domain.to_sym
                @batches[key] ||= Batch.new(domain: key)
              end

              def prune_substrates
                return if @substrates.size <= MAX_SUBSTRATES

                spoiled = @substrates.values.select(&:spoiled?)
                spoiled.each { |s| @substrates.delete(s.id) }
                return if @substrates.size <= MAX_SUBSTRATES

                sorted = @substrates.values.sort_by(&:potency)
                to_remove = sorted.first(@substrates.size - MAX_SUBSTRATES)
                to_remove.each { |s| @substrates.delete(s.id) }
              end
            end
          end
        end
      end
    end
  end
end
