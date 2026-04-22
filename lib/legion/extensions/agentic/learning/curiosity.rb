# frozen_string_literal: true

require 'legion/extensions/agentic/learning/curiosity/version'
require 'legion/extensions/agentic/learning/curiosity/helpers/constants'
require 'legion/extensions/agentic/learning/curiosity/helpers/wonder'
require 'legion/extensions/agentic/learning/curiosity/helpers/wonder_store'
require 'legion/extensions/agentic/learning/curiosity/helpers/gap_detector'
require 'legion/extensions/agentic/learning/curiosity/runners/curiosity'
require 'legion/extensions/agentic/learning/curiosity/actors/decay'
require 'legion/extensions/agentic/learning/curiosity/client'

module Legion
  module Extensions
    # Intrinsic curiosity engine — knowledge gap detection, wonder lifecycle, curiosity-driven learning.
    module Agentic
      module Learning
        module Curiosity
        end
      end
    end
  end
end
