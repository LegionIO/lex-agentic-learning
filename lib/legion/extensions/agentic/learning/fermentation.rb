# frozen_string_literal: true

require 'securerandom'

require_relative 'fermentation/version'
require_relative 'fermentation/helpers/constants'
require_relative 'fermentation/helpers/substrate'
require_relative 'fermentation/helpers/batch'
require_relative 'fermentation/helpers/fermentation_engine'
require_relative 'fermentation/runners/cognitive_fermentation'
require_relative 'fermentation/client'

module Legion
  module Extensions
    module Agentic
      module Learning
        module Fermentation
        end
      end
    end
  end
end
