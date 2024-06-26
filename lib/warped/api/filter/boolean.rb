# frozen_string_literal: true

module Warped
  module Filter
    class Boolean < Base
      RELATIONS = %w[eq neq is_null is_not_null].freeze

      def cast(value)
        return if value.nil?

        casted_value = case value
                       when true, false
                         value
                       when "true", "1", "t", 1
                         true
                       when "false", "0", "f", 0
                         false
                       end

        casted_value.tap do |casted|
          raise ValueError, "#{value} cannot be casted to #{kind}" if casted.nil? && strict
        end
      end

      def html_type
        "text"
      end

      class Value < Value
        def html_value
          case value.class
          when TrueClass
            "true"
          when FalseClass
            "false"
          end
        end
      end
    end
  end
end
