# frozen_string_literal: true

require "bigdecimal"
require "active_support/core_ext/object/blank"

module Warped
  module Filter
    class Decimal < Base
      RELATIONS = %w[eq neq gt gte lt lte between in not_in is_null is_not_null].freeze

      def cast(value)
        return if value.blank?

        casted_value = case value
                       when ::BigDecimal
                         value
                       when ::Integer, ::Float, ::String
                         value.to_d
                       end

        casted_value.tap do |casted|
          raise ValueError, "#{value} cannot be casted to #{kind}" if casted.nil? && strict
        end
      end

      def html_type
        "number"
      end
    end
  end
end
