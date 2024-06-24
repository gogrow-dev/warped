# frozen_string_literal: true

require "active_support/core_ext/object/blank"

module Warped
  module Filter
    class String < Base
      RELATIONS = Queries::Filter::RELATIONS

      def cast(value)
        return if value.blank?

        value.to_s
      rescue StandardError
        raise ValueError, "#{value} cannot be casted to #{kind}" if strict

        nil
      end

      def html_type
        "text"
      end
    end
  end
end
