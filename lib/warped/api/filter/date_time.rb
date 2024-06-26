# frozen_string_literal: true

require "date"
require "active_support/core_ext/object/blank"

module Warped
  module Filter
    class DateTime < Base
      RELATIONS = %w[eq neq gt gte lt lte between is_null is_not_null].freeze

      def cast(value)
        return if value.blank?

        ::DateTime.parse(value)
      rescue ::Date::Error
        raise ValueError, "#{value} cannot be casted to #{kind}" if strict

        nil
      end

      def html_type
        "datetime-local"
      end

      class Value < Value
        def html_value
          value.strftime("%Y-%m-%dT%H:%M:%S")
        end
      end
    end
  end
end
