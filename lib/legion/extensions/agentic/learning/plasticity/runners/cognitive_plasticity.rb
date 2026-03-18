# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module Plasticity
          module Runners
            module CognitivePlasticity
              include Helpers::Constants

              include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

              def create_pathway(label:, engine: nil, pathway_type: :synaptic, initial_strength: 0.3, **)
                eng = engine || default_engine
                pathway = eng.create_pathway(label: label, pathway_type: pathway_type,
                                             initial_strength: initial_strength)
                { success: true, pathway: pathway.to_h }
              end

              def strengthen_pathway(pathway_id:, engine: nil, amount: STRENGTHENING_RATE, **)
                eng = engine || default_engine
                result = eng.strengthen_pathway(pathway_id: pathway_id, amount: amount)
                return { success: false, error: 'pathway not found' } unless result

                { success: true, pathway: result.to_h }
              end

              def weaken_pathway(pathway_id:, engine: nil, amount: STRENGTHENING_RATE, **)
                eng = engine || default_engine
                result = eng.weaken_pathway(pathway_id: pathway_id, amount: amount)
                return { success: false, error: 'pathway not found' } unless result

                { success: true, pathway: result.to_h }
              end

              def rejuvenate_pathway(pathway_id:, engine: nil, amount: 0.1, **)
                eng = engine || default_engine
                result = eng.rejuvenate_pathway(pathway_id: pathway_id, amount: amount)
                return { success: false, error: 'pathway not found' } unless result

                { success: true, pathway: result.to_h }
              end

              def enter_critical_period(engine: nil, **)
                eng = engine || default_engine
                eng.enter_critical_period!
                { success: true, critical_period: true }
              end

              def exit_critical_period(engine: nil, **)
                eng = engine || default_engine
                eng.exit_critical_period!
                { success: true, critical_period: false }
              end

              def prune_weak_pathways(engine: nil, **)
                eng = engine || default_engine
                pruned = eng.prune_weak_pathways!
                { success: true, pruned_count: pruned }
              end

              def strongest_pathways(engine: nil, limit: 5, **)
                eng = engine || default_engine
                pathways = eng.strongest_pathways(limit: limit).map(&:to_h)
                { success: true, pathways: pathways, count: pathways.size }
              end

              def plasticity_report(engine: nil, **)
                eng = engine || default_engine
                { success: true, report: eng.plasticity_report }
              end

              private

              def default_engine
                @default_engine ||= Helpers::PlasticityEngine.new
              end
            end
          end
        end
      end
    end
  end
end
