# frozen_string_literal: true

module Warped
  module Filter
    class Boolean < Base
      RELATIONS = %w[eq neq is_null is_not_null].freeze

      def cast!(value)
        return if value.nil?

        case value
        when true, false
          value
        when "true", "1", "t", 1
          true
        when "false", "0", "f", 0
          false
        else
          raise ValueError, "#{value} cannot be converted to #{kind}"
        end
      end

      def html_type
        "text"
      end
    end
  end
end
