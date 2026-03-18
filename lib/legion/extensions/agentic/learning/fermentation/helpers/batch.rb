# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module Fermentation
          module Helpers
            class Batch
              include Constants

              attr_reader :id, :domain, :substrates, :created_at

              def initialize(domain:)
                @id         = SecureRandom.uuid
                @domain     = domain.to_sym
                @substrates = []
                @created_at = Time.now.utc
              end

              def add_substrate(substrate)
                @substrates << substrate
                substrate
              end

              def ferment_all!(rate = MATURATION_RATE)
                @substrates.each { |s| s.ferment!(rate) }
              end

              def average_potency
                return 0.0 if @substrates.empty?

                (@substrates.sum(&:potency) / @substrates.size).round(10)
              end

              def average_maturity
                return 0.0 if @substrates.empty?

                (@substrates.sum(&:maturity) / @substrates.size).round(10)
              end

              def ripe_count = @substrates.count(&:ripe?)
              def peak_count = @substrates.count(&:peak?)
              def spoiled_count = @substrates.count(&:spoiled?)
              def raw_count = @substrates.count(&:raw?)

              def yield_rate
                return 0.0 if @substrates.empty?

                (ripe_count.to_f / @substrates.size).round(10)
              end

              def ready_to_harvest? = yield_rate >= 0.5

              def to_h
                {
                  id:               @id,
                  domain:           @domain,
                  substrate_count:  @substrates.size,
                  average_potency:  average_potency,
                  average_maturity: average_maturity,
                  ripe_count:       ripe_count,
                  peak_count:       peak_count,
                  spoiled_count:    spoiled_count,
                  yield_rate:       yield_rate,
                  ready_to_harvest: ready_to_harvest?
                }
              end
            end
          end
        end
      end
    end
  end
end
