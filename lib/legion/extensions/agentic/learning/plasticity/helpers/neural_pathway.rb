# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Learning
        module Plasticity
          module Helpers
            class NeuralPathway
              include Constants

              attr_reader :id, :label, :pathway_type, :strength, :plasticity,
                          :activation_count, :created_at

              def initialize(label:, pathway_type: :synaptic, initial_strength: 0.3)
                @id               = SecureRandom.uuid
                @label            = label
                @pathway_type     = pathway_type.to_sym
                @strength         = initial_strength.to_f.clamp(0.0, 1.0)
                @plasticity       = DEFAULT_LEARNING_RATE
                @activation_count = 0
                @created_at       = Time.now.utc
              end

              def strengthen!(amount: STRENGTHENING_RATE, critical_period: false)
                multiplier = critical_period ? CRITICAL_PERIOD_MULTIPLIER : 1.0
                effective = (amount * multiplier * @plasticity).round(10)
                @strength = (@strength + effective).clamp(0.0, 1.0).round(10)
                @activation_count += 1
                mature!
                self
              end

              def weaken!(amount: STRENGTHENING_RATE)
                effective = (amount * @plasticity).round(10)
                @strength = (@strength - effective).clamp(0.0, 1.0).round(10)
                self
              end

              def prune_candidate?
                @strength < PRUNING_THRESHOLD
              end

              def mature!
                @plasticity = (@plasticity - MATURATION_RATE).clamp(0.1, 1.0).round(10)
              end

              def rejuvenate!(amount: 0.1)
                @plasticity = (@plasticity + amount).clamp(0.1, 1.0).round(10)
                self
              end

              def strength_label
                match = STRENGTH_LABELS.find { |range, _| range.cover?(@strength) }
                match ? match.last : :nascent
              end

              def plasticity_label
                match = PLASTICITY_LABELS.find { |range, _| range.cover?(@plasticity) }
                match ? match.last : :crystallized
              end

              def to_h
                {
                  id:               @id,
                  label:            @label,
                  pathway_type:     @pathway_type,
                  strength:         @strength,
                  strength_label:   strength_label,
                  plasticity:       @plasticity,
                  plasticity_label: plasticity_label,
                  activation_count: @activation_count,
                  prune_candidate:  prune_candidate?,
                  created_at:       @created_at
                }
              end
            end
          end
        end
      end
    end
  end
end
