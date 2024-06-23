# frozen_string_literal: true

require "bigdecimal"
require "active_support/core_ext/object/blank"

module Warped
  module Filter
    class Decimal < Base
      RELATIONS = %w[eq neq gt gte lt lte between in not_in is_null is_not_null].freeze

      def cast(value)
        return if value.blank?

        case value
        when ::BigDecimal
          value
        when ::Integer, ::Float, ::String
          value.to_d
        end
      end

      def html_type
        "number"
      end
    end
  end
end
