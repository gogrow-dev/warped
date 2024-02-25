# frozen_string_literal: true

require "boosted/services/base"

module Boosted
  module Queries
    class Sort
      SORT_DIRECTIONS = %w[asc desc].freeze
      NULLS_SORT_DIRECTION = %w[asc_nulls_first asc_nulls_last desc_nulls_first desc_nulls_last].freeze

      # @param scope [ActiveRecord::Relation] the scope to sort
      # @param sort_key [String, Symbol] the key to sort by
      # @param sort_direction [String, Symbol] the direction to sort by
      # @return [ActiveRecord::Relation] the sorted scope
      def self.call(scope, sort_key:, sort_direction: :desc)
        new(scope, sort_key:, sort_direction:).call
      end

      # @param scope [ActiveRecord::Relation] the scope to sort
      # @param sort_key [String, Symbol] the key to sort by
      # @param sort_direction [String, Symbol] the direction to sort by
      # @return [ActiveRecord::Relation] the sorted scope
      def initialize(scope, sort_key:, sort_direction: :desc)
        super()
        @scope = scope
        @sort_key = sort_key.to_s
        @sort_direction = sort_direction.to_s.downcase
      end

      # @return [ActiveRecord::Relation]
      def call
        validate_sort_direction!(sort_direction)

        order = if NULLS_SORT_DIRECTION.include?(sort_direction)
                  arel_order
                else
                  { sort_key => sort_direction }
                end

        scope.reorder(order)
      end

      private

      attr_reader :scope, :sort_key, :sort_direction

      def validate_sort_direction!(sort_direction)
        return if SORT_DIRECTIONS.include?(sort_direction) || NULLS_SORT_DIRECTION.include?(sort_direction)

        raise ArgumentError, "Invalid sort direction: #{sort_direction}, must be one of #{SORT_DIRECTIONS}"
      end

      def arel_order
        arel_table.send(order_nulls_direction.first).send("nulls_#{order_nulls_direction.last}")
      end

      def arel_table
        sort_key_arr = sort_key.split(".")

        if sort_key_arr.size == 1
          # sort_key has format 'column'
          scope.klass.arel_table[sort_key]
        else
          # sort_key has format 'table.column'
          Arel::Table.new(sort_key_arr.first)[sort_key_arr.last]
        end
      end

      def order_nulls_direction
        @order_nulls_direction ||= begin
          order_nulls_dir = sort_direction.split("_")
          [order_nulls_dir.first, order_nulls_dir.last]
        end
      end
    end
  end
end
