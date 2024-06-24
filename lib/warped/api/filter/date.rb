# frozen_string_literal: true

require "date"
require "active_support/core_ext/object/blank"

module Warped
  module Filter
    class Date < Base
      RELATIONS = %w[eq neq gt gte lt lte between is_null is_not_null].freeze

      def cast(value)
        return if value.blank?

        ::Date.parse(value)
      rescue ::Date::Error
        raise ValueError, "#{value} cannot be casted to #{kind}" if strict

        nil
      end

      def html_type
        "date"
      end
    end
  end
end
