# frozen_string_literal: true

require "active_support/core_ext/object/blank"

module Warped
  module Filter
    class Integer < Base
      RELATIONS = %w[eq neq gt gte lt lte between in not_in is_null is_not_null].freeze

      def cast(value)
        return if value.blank?

        case value
        when ::Integer
          value
        when ::String
          value.to_i if value.match?(/\A-?\d+\z/)
        when ::Float, ::BigDecimal
          value.to_i
        end
      end

      def html_type
        "number"
      end
    end
  end
end
