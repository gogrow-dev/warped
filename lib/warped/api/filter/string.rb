# frozen_string_literal: true

module Warped
  module Filter
    class String < Base
      RELATIONS = Queries::Filter::RELATIONS

      def cast!(value)
        return if value.nil?

        value.to_s
      rescue StandardError
        raise ValueError, "#{value} cannot be casted to #{kind}"
      end

      def html_type
        "text"
      end
    end
  end
end
