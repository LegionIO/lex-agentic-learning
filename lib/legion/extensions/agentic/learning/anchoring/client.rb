# frozen_string_literal: true

require 'legion/extensions/agentic/learning/anchoring/helpers/constants'
require 'legion/extensions/agentic/learning/anchoring/helpers/anchor'
require 'legion/extensions/agentic/learning/anchoring/helpers/anchor_store'
require 'legion/extensions/agentic/learning/anchoring/runners/anchoring'

module Legion
  module Extensions
    module Agentic
      module Learning
        module Anchoring
          class Client
            include Runners::Anchoring

            attr_reader :anchor_store

            def initialize(anchor_store: nil, **)
              @anchor_store = anchor_store || Helpers::AnchorStore.new
            end
          end
        end
      end
    end
  end
end
