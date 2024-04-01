# frozen_string_literal: true

require "warped/services/base"

module Warped
  module Queries
    ##
    # Filter a scope by a set of conditions
    #
    # This class provides a simple interface for filtering a scope by a set of conditions.
    # The conditions are passed as an array of hashes, where each hash contains the following
    # keys:
    # - +relation+: the relation to use for the filter (e.g. "eq", "gt", "in", etc.)
    # - +field+: the field to filter by
    # - +value+: the value to filter by
    #
    #
    # @example Filter a scope by a set of conditions
    #   Warped::Queries::Filter.call(User.all, filter_conditions: [
    #     { relation: "eq", field: :first_name, value: "John" },
    #     { relation: "gt", field: :age, value: 18 }
    #   ])
    #   # => #<ActiveRecord::Relation [...]>
    #
    # @see RELATIONS
    # To see the list of available relations, check the +RELATIONS+ constant.
    class Filter
      RELATIONS = %w[eq neq gt gte lt lte between in not_in starts_with ends_with contains is_null is_not_null].freeze

      # @param scope [ActiveRecord::Relation] the scope to filter
      # @param filter_conditions [Array<Hash>] the conditions to filter by
      # @return [ActiveRecord::Relation] the filtered scope
      def self.call(scope, filter_conditions:)
        new(scope, filter_conditions:).call
      end

      # @param scope [ActiveRecord::Relation] the scope to filter
      # @param filter_conditions [Array<Hash>] the conditions to filter by
      # @return [ActiveRecord::Relation] the filtered scope
      def initialize(scope, filter_conditions:)
        super()
        @scope = scope
        @filter_conditions = filter_conditions
      end

      def call
        filter_conditions.reduce(scope) do |scope, filter_condition|
          relation = filter_condition[:relation].to_s
          field = filter_condition[:field]
          value = filter_condition[:value]

          validate_relation!(relation)
          filtered_scope(scope, relation, field, value)
        end
      end

      private

      attr_reader :scope, :filter_conditions

      def validate_relation!(relation)
        return if RELATIONS.include?(relation)

        raise ArgumentError, "relation must be one of: #{RELATIONS.join(", ")}"
      end

      def filtered_scope(scope, relation, field, value)
        case relation
        when "eq"
          scope.where(field => value)
        when "in"
          scope.where(field => Array.wrap(value))
        when "neq", "not_in"
          scope.where.not(field => value)
        when "between"
          scope.where(field => value.first..value.last)
        when "starts_with"
          scope.where(arel_table_for(scope, field).matches("#{value}%"))
        when "ends_with"
          scope.where(arel_table_for(scope, field).matches("%#{value}"))
        when "contains"
          scope.where(arel_table_for(scope, field).matches("%#{value}%"))
        when "is_null"
          scope.where(field => nil)
        when "is_not_null"
          scope.where.not(field => nil)
        when "gt"
          scope.where.not(field => ...value)
        when "gte"
          scope.where(field => value..)
        when "lt"
          scope.where(field => ...value)
        when "lte"
          scope.where(field => ..value)
        end
      end

      # @param scope [ActiveRecord::Relation]
      # @param field [String|Symbol]
      # @return [Arel::Table]
      #  The arel table for the given field. If the field has the format "table.column",
      #  the method will return the table for the field's table and column.
      def arel_table_for(scope, field)
        column, relation = field.to_s.split(".").reverse
        return scope.arel_table[column.to_sym] unless relation

        scope.arel_table.alias(relation.to_sym)[column.to_sym]
      end
    end
  end
end
