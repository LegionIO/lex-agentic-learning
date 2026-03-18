# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module Fermentation
          module Runners
            module CognitiveFermentation
              include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

              def create_substrate(substrate_type:, domain:, content: '', potency: nil,
                                   volatility: nil, engine: nil, **)
                eng = engine || @default_engine
                sub = eng.create_substrate(substrate_type: substrate_type, domain: domain,
                                           content: content, potency: potency, volatility: volatility)
                { success: true, substrate: sub.to_h }
              end

              def ferment(substrate_id:, rate: nil, engine: nil, **)
                eng = engine || @default_engine
                sub = eng.ferment(substrate_id: substrate_id,
                                  rate:         rate || Helpers::Constants::MATURATION_RATE)
                return { success: false, error: 'substrate not found' } unless sub

                { success: true, substrate: sub.to_h }
              end

              def catalyze(substrate_id:, catalyst_type:, engine: nil, **)
                eng = engine || @default_engine
                sub = eng.catalyze(substrate_id: substrate_id, catalyst_type: catalyst_type)
                return { success: false, error: 'substrate not found' } unless sub

                { success: true, substrate: sub.to_h }
              end

              def ferment_all(rate: nil, engine: nil, **)
                eng = engine || @default_engine
                eng.ferment_all!(rate: rate || Helpers::Constants::MATURATION_RATE)
                { success: true }
              end

              def list_ripe(engine: nil, **)
                eng = engine || @default_engine
                ripe = eng.ripe_substrates
                { success: true, count: ripe.size, substrates: ripe.map(&:to_h) }
              end

              def fermentation_status(engine: nil, **)
                eng = engine || @default_engine
                report = eng.fermentation_report
                { success: true, **report }
              end
            end
          end
        end
      end
    end
  end
end
