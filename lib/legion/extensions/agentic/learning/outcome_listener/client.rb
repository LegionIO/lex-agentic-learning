# frozen_string_literal: true

require 'legion/extensions/agentic/learning/meta_learning/client'
require 'legion/extensions/agentic/learning/scaffolding/client'
require 'legion/extensions/agentic/learning/learning_rate/client'
require 'legion/extensions/agentic/learning/outcome_listener/helpers/constants'
require 'legion/extensions/agentic/learning/outcome_listener/helpers/domain_extractor'
require 'legion/extensions/agentic/learning/outcome_listener/helpers/lesson_builder'
require 'legion/extensions/agentic/learning/outcome_listener/runners/outcome_listener'

module Legion
  module Extensions
    module Agentic
      module Learning
        module OutcomeListener
          class Client
            include Runners::OutcomeListener

            # rubocop:disable ThreadSafety/ClassInstanceVariable
            class << self
              def meta_client
                @meta_client ||= Legion::Extensions::Agentic::Learning::MetaLearning::Client.new
              end

              def scaffolding_client
                @scaffolding_client ||= Legion::Extensions::Agentic::Learning::Scaffolding::Client.new
              end

              def learning_rate_client
                @learning_rate_client ||= Legion::Extensions::Agentic::Learning::LearningRate::Client.new
              end

              def domain_map
                @domain_map ||= {}
              end

              def outcome_mutex
                @outcome_mutex ||= Mutex.new
              end

              def processed_outcomes
                @processed_outcomes ||= {}
              end

              def reset!
                @meta_client = nil
                @scaffolding_client = nil
                @learning_rate_client = nil
                @domain_map = nil
                @processed_outcomes = nil
              end
            end
            # rubocop:enable ThreadSafety/ClassInstanceVariable
          end
        end
      end
    end
  end
end
