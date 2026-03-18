# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module Fermentation
          module Helpers
            class Substrate
              include Constants

              attr_reader :id, :substrate_type, :domain, :content, :potency,
                          :maturity, :volatility, :stage, :created_at, :catalysts_applied

              def initialize(substrate_type:, domain:, content: '', potency: nil, volatility: nil)
                @id                = SecureRandom.uuid
                @substrate_type    = substrate_type.to_sym
                @domain            = domain.to_sym
                @content           = content
                @potency           = (potency || DEFAULT_POTENCY).to_f.clamp(0.0, 1.0)
                @maturity          = 0.0
                @volatility        = (volatility || 0.5).to_f.clamp(0.0, 1.0)
                @stage             = :inoculation
                @catalysts_applied = []
                @created_at        = Time.now.utc
              end

              def ferment!(rate = MATURATION_RATE)
                @maturity = (@maturity + rate).clamp(0.0, 1.0).round(10)
                @volatility = (@volatility - VOLATILITY_DECAY).clamp(0.0, 1.0).round(10)
                advance_stage!
                @potency = compute_potency
              end

              def catalyze!(catalyst_type)
                @catalysts_applied << catalyst_type.to_sym
                @potency = (@potency + CATALYSIS_BOOST).clamp(0.0, 1.0).round(10)
                @volatility = (@volatility + 0.05).clamp(0.0, 1.0).round(10)
              end

              def spoil!
                @potency = (@potency * 0.5).round(10)
                @stage = :over_fermented
              end

              def ripe? = @potency >= RIPE_THRESHOLD && @maturity >= 0.5
              def peak? = @potency >= PEAK_THRESHOLD && @stage == :peak
              def spoiled? = @potency < SPOILAGE_THRESHOLD
              def raw? = @stage == :inoculation
              def aging? = @stage == :aging
              def over_fermented? = @stage == :over_fermented
              def multi_catalyzed? = @catalysts_applied.uniq.size >= 3

              STAGE_THRESHOLDS = {
                (0.0...0.1)   => :inoculation,
                (0.1...0.25)  => :primary_fermentation,
                (0.25...0.4)  => :secondary_fermentation,
                (0.4...0.55)  => :conditioning,
                (0.55...0.7)  => :maturation,
                (0.7...0.85)  => :aging,
                (0.85...0.95) => :peak,
                (0.95..)      => :over_fermented
              }.freeze

              def age
                ((Time.now.utc - @created_at) / 60.0).round(2)
              end

              def to_h
                {
                  id:                @id,
                  substrate_type:    @substrate_type,
                  domain:            @domain,
                  content:           @content,
                  potency:           @potency.round(10),
                  maturity:          @maturity.round(10),
                  volatility:        @volatility.round(10),
                  stage:             @stage,
                  ripe:              ripe?,
                  peak:              peak?,
                  spoiled:           spoiled?,
                  catalysts_applied: @catalysts_applied.uniq,
                  age_minutes:       age,
                  created_at:        @created_at.iso8601
                }
              end

              private

              def advance_stage!
                @stage = STAGE_THRESHOLDS.each do |range, stage|
                  break stage if range.cover?(@maturity)
                end
              end

              def compute_potency
                base = @potency
                base += 0.02 if @stage == :peak
                base -= OVER_FERMENTED_DECAY if @stage == :over_fermented
                base.clamp(0.0, 1.0).round(10)
              end
            end
          end
        end
      end
    end
  end
end
