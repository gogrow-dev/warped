# frozen_string_literal: true

require "bigdecimal"

module Warped
  module Filter
    class Decimal < Base
      RELATIONS = %w[eq neq gt gte lt lte between in not_in is_null is_not_null].freeze

      def cast!(value)
        return if value.nil?

        case value
        when ::BigDecimal
          value
        when ::Integer, ::Float, ::String
          value.to_d
        else
          raise ValueError, "#{value} cannot be converted to #{kind}"
        end
      end

      def html_type
        "number"
      end
    end
  end
end
