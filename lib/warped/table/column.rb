# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"

module Warped
  module Table
    class Column
      attr_reader :parameter_name, :method, :options

      # @param parameter_name [String] The parameter name to be used by the column
      # @param display_name [String] The display name of the column
      # @param method [String, Symbol, Proc] The method to be called on the record to get the content of the column
      def initialize(parameter_name, display_name = nil, method: nil, **options)
        @parameter_name = parameter_name
        @display_name = display_name
        @options = options
        @method = method.presence || parameter_name
      end

      def display_name
        @display_name.presence || parameter_name.to_s.humanize
      end

      def content_for(record)
        if method.is_a?(Proc)
          method.call(record)
        else
          record.public_send(method)
        end
      end
    end
  end
end
