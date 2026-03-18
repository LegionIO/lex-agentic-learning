# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module Agentic
      module Learning
        module Procedural
          module Helpers
            class Production
              include Constants

              attr_reader :id, :condition, :action, :domain, :skill_id,
                          :execution_count, :success_count, :created_at, :last_executed_at

              def initialize(condition:, action:, domain:, skill_id:)
                @id               = SecureRandom.uuid
                @condition        = condition
                @action           = action
                @domain           = domain
                @skill_id         = skill_id
                @execution_count  = 0
                @success_count    = 0
                @created_at       = Time.now.utc
                @last_executed_at = @created_at
              end

              def execute!(success:)
                @execution_count  += 1
                @success_count    += 1 if success
                @last_executed_at  = Time.now.utc
              end

              def success_rate
                return 0.0 if @execution_count.zero?

                @success_count.to_f / @execution_count
              end

              def reliable?
                success_rate >= 0.7 && @execution_count >= 3
              end

              def to_h
                {
                  id:               @id,
                  condition:        @condition,
                  action:           @action,
                  domain:           @domain,
                  skill_id:         @skill_id,
                  execution_count:  @execution_count,
                  success_count:    @success_count,
                  success_rate:     success_rate,
                  reliable:         reliable?,
                  created_at:       @created_at,
                  last_executed_at: @last_executed_at
                }
              end
            end
          end
        end
      end
    end
  end
end
