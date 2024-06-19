# frozen_string_literal: true

require "active_support/core_ext/module/delegation"

module Warped
  module Table
    class Action
      attr_reader :options

      delegate :[], to: :options

      # @param name [String | Symbol | Proc] The name of the action
      # @param path [String | Symbol | Proc] The path of the action
      def initialize(name, path, **options)
        @name = name
        @path = path
        @options = options
      end

      def path(...)
        return @path.call(...) if @path.is_a?(Proc)

        @path
      end

      def name(...)
        return @name.call(...) if @name.is_a?(Proc)

        @name
      end
    end
  end
end
