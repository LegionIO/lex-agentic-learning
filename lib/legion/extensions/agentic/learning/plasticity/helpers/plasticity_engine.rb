# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module Plasticity
          module Helpers
            class PlasticityEngine
              include Constants

              def initialize
                @pathways        = {}
                @critical_period = false
              end

              def create_pathway(label:, pathway_type: :synaptic, initial_strength: 0.3)
                prune_if_needed
                pathway = NeuralPathway.new(label: label, pathway_type: pathway_type,
                                            initial_strength: initial_strength)
                @pathways[pathway.id] = pathway
                pathway
              end

              def strengthen_pathway(pathway_id:, amount: STRENGTHENING_RATE)
                pathway = @pathways[pathway_id]
                return nil unless pathway

                pathway.strengthen!(amount: amount, critical_period: @critical_period)
              end

              def weaken_pathway(pathway_id:, amount: STRENGTHENING_RATE)
                pathway = @pathways[pathway_id]
                return nil unless pathway

                pathway.weaken!(amount: amount)
              end

              def rejuvenate_pathway(pathway_id:, amount: 0.1)
                pathway = @pathways[pathway_id]
                return nil unless pathway

                pathway.rejuvenate!(amount: amount)
              end

              def enter_critical_period!
                @critical_period = true
              end

              def exit_critical_period!
                @critical_period = false
              end

              def critical_period?
                @critical_period
              end

              def prune_weak_pathways!
                candidates = @pathways.values.select(&:prune_candidate?)
                candidates.each { |p| @pathways.delete(p.id) }
                candidates.size
              end

              def pathways_by_type(pathway_type:)
                pt = pathway_type.to_sym
                @pathways.values.select { |p| p.pathway_type == pt }
              end

              def strongest_pathways(limit: 5)
                @pathways.values.sort_by { |p| -p.strength }.first(limit)
              end

              def weakest_pathways(limit: 5)
                @pathways.values.sort_by(&:strength).first(limit)
              end

              def average_strength
                return 0.0 if @pathways.empty?

                strengths = @pathways.values.map(&:strength)
                (strengths.sum / strengths.size).round(10)
              end

              def average_plasticity
                return DEFAULT_LEARNING_RATE if @pathways.empty?

                plasticities = @pathways.values.map(&:plasticity)
                (plasticities.sum / plasticities.size).round(10)
              end

              def prune_candidates_count
                @pathways.values.count(&:prune_candidate?)
              end

              def plasticity_report
                {
                  total_pathways:     @pathways.size,
                  critical_period:    @critical_period,
                  average_strength:   average_strength,
                  average_plasticity: average_plasticity,
                  prune_candidates:   prune_candidates_count,
                  strongest:          strongest_pathways(limit: 3).map(&:to_h)
                }
              end

              def to_h
                {
                  total_pathways:     @pathways.size,
                  critical_period:    @critical_period,
                  average_strength:   average_strength,
                  average_plasticity: average_plasticity,
                  prune_candidates:   prune_candidates_count
                }
              end

              private

              def prune_if_needed
                return if @pathways.size < MAX_PATHWAYS

                weakest = @pathways.values.min_by(&:strength)
                @pathways.delete(weakest.id) if weakest
              end
            end
          end
        end
      end
    end
  end
end
