# frozen_string_literal: true

require "active_support/core_ext/module/delegation"

module Warped
  class Sort
    class Value
      attr_reader :sort

      delegate :name, :alias_name, :parameter_name, to: :sort

      def initialize(sort, direction)
        @sort = sort
        @direction = direction
      end

      def direction
        sort.direction!(@direction)
      end

      def opposite_direction
        sort.opposite_direction(direction)
      end

      def asc?
        %w[asc asc_nulls_first asc_nulls_last].include?(direction)
      end

      def desc?
        %w[desc desc_nulls_first desc_nulls_last].include?(direction)
      end
    end
  end
end
