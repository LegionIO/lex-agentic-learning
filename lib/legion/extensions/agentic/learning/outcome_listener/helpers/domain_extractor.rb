# frozen_string_literal: true

module Legion
  module Extensions
    module Agentic
      module Learning
        module OutcomeListener
          module Helpers
            module DomainExtractor
              RUNNER_PATTERN = /Legion::Extensions::(?:Agentic::)?(\w+)/

              module_function

              def extract(runner_class_name)
                return 'unknown' if runner_class_name.nil? || runner_class_name.empty?

                match = runner_class_name.match(RUNNER_PATTERN)
                return snake_case(match[1]) if match

                segments = runner_class_name.split('::')
                return snake_case(segments[-2]) if segments.size >= 2

                snake_case(segments.last)
              end

              def snake_case(str)
                str.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                   .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                   .downcase
              end
            end
          end
        end
      end
    end
  end
end
