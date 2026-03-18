# frozen_string_literal: true

require 'legion/extensions/actors/every'

module Legion
  module Extensions
    module Agentic
      module Learning
        module Hebbian
          module Actor
            class Decay < Legion::Extensions::Actors::Every
              def runner_class
                Legion::Extensions::Agentic::Learning::Hebbian::Runners::HebbianAssembly
              end

              def runner_function
                'update_hebbian'
              end

              def time
                60
              end

              def run_now?
                false
              end

              def use_runner?
                false
              end

              def check_subtask?
                false
              end

              def generate_task?
                false
              end
            end
          end
        end
      end
    end
  end
end
