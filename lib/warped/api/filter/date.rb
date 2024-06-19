# frozen_string_literal: true

require "date"

module Warped
  module Filter
    class Date < Base
      RELATIONS = %w[eq neq gt gte lt lte between is_null is_not_null].freeze

      def cast!(value)
        return if value.nil?

        ::Date.parse(value)
      rescue ::Date::Error
        raise ValueError, "#{value} cannot be converted to #{kind}"
      end

      def html_type
        "date"
      end
    end
  end
end
