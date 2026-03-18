# frozen_string_literal: true

require 'legion/extensions/agentic/learning/preference_learning/helpers/constants'
require 'legion/extensions/agentic/learning/preference_learning/helpers/option'
require 'legion/extensions/agentic/learning/preference_learning/helpers/preference_engine'
require 'legion/extensions/agentic/learning/preference_learning/runners/preference_learning'

module Legion
  module Extensions
    module Agentic
      module Learning
        module PreferenceLearning
          class Client
            include Runners::PreferenceLearning

            def initialize(**)
              @preference_engine = Helpers::PreferenceEngine.new
            end

            private

            attr_reader :preference_engine
          end
        end
      end
    end
  end
end
