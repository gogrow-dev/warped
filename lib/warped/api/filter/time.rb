# frozen_string_literal: true

module Warped
  module Filter
    class Time < Base
      RELATIONS = %w[eq neq gt gte lt lte between is_null is_not_null].freeze

      def cast!(value)
        return if value.nil?

        ::Time.parse(value)
      rescue StandardError
        raise ValueError, "#{value} cannot be casted to #{kind}"
      end

      def html_type
        "time"
      end
    end
  end
end
