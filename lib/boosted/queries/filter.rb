# frozen_string_literal: true

require "boosted/services/base"

module Boosted
  module Queries
    ##
    # Filter a scope by a set of conditions
    #
    # This class provides a simple interface for filtering a scope by a set of conditions.
    # The conditions are passed as an array of hashes, where each hash contains the following
    # keys:
    # - +relation+: the relation to use for the filter (e.g. "=", ">", "in", etc.)
    # - +field+: the field to filter by
    # - +value+: the value to filter by
    #
    #
    # @example Filter a scope by a set of conditions
    #   Boosted::Queries::Filter.call(User.all, filter_conditions: [
    #     { relation: "=", field: :first_name, value: "John" },
    #     { relation: ">", field: :age, value: 18 }
    #   ])
    #   # => #<ActiveRecord::Relation [...]>
    #
    # @see RELATIONS
    # To see the list of available relations, check the +RELATIONS+ constant.
    class Filter
      RELATIONS = %w[= != > >= < <= between in not_in starts_with ends_with contains is_null is_not_null].freeze

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
        when "=", "in"
          scope.where(field => value)
        when "!=", "not_in"
          scope.where.not(field => value)
        when "between"
          scope.where("#{field} BETWEEN ? AND ?", value.first, value.last)
        when "starts_with"
          scope.where("#{field} LIKE ?", "#{value}%")
        when "ends_with"
          scope.where("#{field} LIKE ?", "%#{value}")
        when "contains"
          scope.where("#{field} LIKE ?", "%#{value}%")
        when "is_null"
          scope.where(field => nil)
        when "is_not_null"
          scope.where.not(field => nil)
        else # '>', '>=', '<', '<='
          scope.where("#{field} #{relation} ?", value)
        end
      end
    end
  end
end
