# frozen_string_literal: true

require 'legion/extensions/agentic/learning/curiosity/helpers/constants'
require 'legion/extensions/agentic/learning/curiosity/helpers/wonder'
require 'legion/extensions/agentic/learning/curiosity/helpers/wonder_store'
require 'legion/extensions/agentic/learning/curiosity/helpers/gap_detector'
require 'legion/extensions/agentic/learning/curiosity/runners/curiosity'

module Legion
  module Extensions
    module Agentic
      module Learning
        module Curiosity
          # Standalone client for curiosity operations without the full framework.
          class Client
            include Runners::Curiosity

            attr_reader :wonder_store

            def initialize(store: nil, **)
              @wonder_store = store || Helpers::WonderStore.new
            end
          end
        end
      end
    end
  end
end
