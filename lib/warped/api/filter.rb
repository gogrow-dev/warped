# frozen_string_literal: true

require "active_support/core_ext/module/delegation"

module Warped
  module Filter
    class ValueError < StandardError; end
    class RelationError < StandardError; end

    class << self
      delegate :build, to: Factory
    end
  end
end
