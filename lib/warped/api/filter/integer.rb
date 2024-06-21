# frozen_string_literal: true

module Warped
  module Filter
    class Integer < Base
      RELATIONS = %w[eq neq gt gte lt lte between in not_in is_null is_not_null].freeze

      def cast!(value)
        return if value.nil?

        case value
        when ::Integer
          value
        when ::String

          raise ValueError, "#{value} cannot be casted to #{kind}" unless value.match?(/\A-?\d+\z/)

          value.to_i
        when ::Float, ::BigDecimal
          value.to_i
        else
          raise ValueError, "#{value} cannot be casted to #{kind}"
        end
      end

      def html_type
        "number"
      end
    end
  end
end
