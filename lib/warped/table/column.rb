# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"

module Warped
  module Table
    class Column
      attr_reader :parameter_name, :method_name, :options
      attr_accessor :filter, :sort

      # @param display_name [String] The display name of the column
      def initialize(parameter_name, display_name = nil, method_name: nil, **options)
        @parameter_name = parameter_name
        @display_name = display_name
        @options = options
        @method_name = method_name.presence || parameter_name
      end

      def display_name
        @display_name.presence || parameter_name.to_s.humanize
      end
    end
  end
end
