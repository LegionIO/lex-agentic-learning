# frozen_string_literal: true

require 'legion/extensions/agentic/learning/scaffolding/helpers/constants'
require 'legion/extensions/agentic/learning/scaffolding/helpers/scaffold'
require 'legion/extensions/agentic/learning/scaffolding/helpers/scaffolding_engine'
require 'legion/extensions/agentic/learning/scaffolding/runners/cognitive_scaffolding'

module Legion
  module Extensions
    module Agentic
      module Learning
        module Scaffolding
          class Client
            include Runners::CognitiveScaffolding

            attr_reader :engine

            def initialize(engine: nil, **)
              @engine = engine || Helpers::ScaffoldingEngine.new
            end
          end
        end
      end
    end
  end
end
