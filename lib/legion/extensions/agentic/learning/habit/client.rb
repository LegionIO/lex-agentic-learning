# frozen_string_literal: true

require 'legion/extensions/agentic/learning/habit/helpers/constants'
require 'legion/extensions/agentic/learning/habit/helpers/action_sequence'
require 'legion/extensions/agentic/learning/habit/helpers/habit_store'
require 'legion/extensions/agentic/learning/habit/runners/habit'

module Legion
  module Extensions
    module Agentic
      module Learning
        module Habit
          class Client
            include Runners::Habit

            attr_reader :habit_store

            def initialize(habit_store: nil, **)
              @habit_store = habit_store || Helpers::HabitStore.new
            end
          end
        end
      end
    end
  end
end
