# frozen_string_literal: true

require 'legion/extensions/agentic/learning/epistemic_curiosity/helpers/constants'
require 'legion/extensions/agentic/learning/epistemic_curiosity/helpers/knowledge_gap'
require 'legion/extensions/agentic/learning/epistemic_curiosity/helpers/curiosity_engine'
require 'legion/extensions/agentic/learning/epistemic_curiosity/runners/epistemic_curiosity'

module Legion
  module Extensions
    module Agentic
      module Learning
        module EpistemicCuriosity
          class Client
            include Runners::EpistemicCuriosity

            def initialize(**)
              @engine = Helpers::CuriosityEngine.new
            end

            private

            attr_reader :engine
          end
        end
      end
    end
  end
end
