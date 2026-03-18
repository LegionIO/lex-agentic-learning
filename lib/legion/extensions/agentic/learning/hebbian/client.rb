# frozen_string_literal: true

require 'legion/extensions/agentic/learning/hebbian/helpers/constants'
require 'legion/extensions/agentic/learning/hebbian/helpers/unit'
require 'legion/extensions/agentic/learning/hebbian/helpers/assembly'
require 'legion/extensions/agentic/learning/hebbian/helpers/assembly_network'
require 'legion/extensions/agentic/learning/hebbian/runners/hebbian_assembly'

module Legion
  module Extensions
    module Agentic
      module Learning
        module Hebbian
          class Client
            include Runners::HebbianAssembly

            def initialize(network: nil, **)
              @network = network || Helpers::AssemblyNetwork.new
            end

            private

            attr_reader :network
          end
        end
      end
    end
  end
end
