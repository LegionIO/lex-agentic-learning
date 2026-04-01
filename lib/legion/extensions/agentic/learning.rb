# frozen_string_literal: true

require_relative 'learning/version'
require_relative 'learning/plasticity'
require_relative 'learning/scaffolding'
require_relative 'learning/fermentation'
require_relative 'learning/chrysalis'
require_relative 'learning/catalyst'
require_relative 'learning/curiosity'
require_relative 'learning/epistemic_curiosity'
require_relative 'learning/habit'
require_relative 'learning/hebbian'
require_relative 'learning/learning_rate'
require_relative 'learning/meta_learning'
require_relative 'learning/preference_learning'
require_relative 'learning/procedural'
require_relative 'learning/anchoring'
require_relative 'learning/outcome_listener'

module Legion
  module Extensions
    module Agentic
      module Learning
        extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core, false

        def self.remote_invocable?
          false
        end
      end
    end
  end
end
