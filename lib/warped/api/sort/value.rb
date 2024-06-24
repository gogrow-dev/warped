# frozen_string_literal: true

require "active_support/core_ext/module/delegation"

module Warped
  class Sort
    class Value
      attr_reader :sort

      delegate :name, :alias_name, :parameter_name, to: :sort

      # @param sort [Warped::Sort] The sort object
      # @param direction [String] The sort direction.
      def initialize(sort, direction)
        @sort = sort
        @direction = direction
      end

      # @return [String] The sort direction.
      def direction
        sort.direction!(@direction)
      end

      # @return [String] The opposite sort direction.
      def opposite_direction
        sort.opposite_direction(direction)
      end

      # @return [Boolean] Whether the sort is ascending.
      def asc?
        %w[asc asc_nulls_first asc_nulls_last].include?(direction)
      end

      # @return [Boolean] Whether the sort is descending.
      def desc?
        %w[desc desc_nulls_first desc_nulls_last].include?(direction)
      end
    end
  end
end
