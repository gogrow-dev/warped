# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/enumerable"

module Boosted
  module Controllers
    # Provides functionality for filtering records from an +ActiveRecord::Relation+ in a controller.
    #
    # Example usage:
    #
    #   class UsersController < ApplicationController
    #     include Filterable
    #
    #     filterable_by :name, :created_at, 'accounts.kind'
    #
    #     def index
    #       scope = filter(User.joins(:account))
    #       render json: scope
    #     end
    #   end
    #
    # Example requests:
    #   GET /users?name=John
    #   GET /users?created_at=2020-01-01
    #   GET /users?accounts.kind=premium
    #   GET /users?accounts.kind=premium&accounts.kind.rel=not_eq
    #
    # Filters can be combined:
    #   GET /users?name=John&created_at=2020-01-01
    #
    # Renaming filter keys:
    #
    # In some cases, you may not want to expose the actual column names to the client.
    # In such cases, you can rename the filter keys by passing a hash to the +filterable_by+ method.
    #
    # Example:
    #
    #   class UsersController < ApplicationController
    #     include Filterable
    #
    #     filterable_by :name, :created_at, 'accounts.kind' => 'kind'
    #
    #     def index
    #       scope = filter(User.joins(:account))
    #       render json: scope
    #     end
    #   end
    #
    # Example requests:
    #   GET /users?kind=premium
    #
    # Using relations:
    #
    # In some cases, you may want to filter records based on a relation.
    # For example, you may want to filter users based on operands like:
    # - greater than
    # - less than
    # - not equal
    # To see the full list of operands, check the `Boosted::Queries::Filter::RELATIONS` constant.
    #
    # To use the operands, you must pass a parameter appended with `.rel`, and the value of a valid operand.
    #
    # Example requests:
    #   GET /users?created_at=2020-01-01&created_at.rel=>
    #   GET /users?created_at=2020-01-01&created_at.rel=<
    #   GET /users?created_at=2020-01-01&created_at.rel=not_eq
    #
    # When the operand relation requires multiple values, like +in+, +not_in+, or +between+,
    # you can pass an array of values.
    #
    # Example requests:
    #   GET /users?created_at[]=2020-01-01&created_at[]=2020-01-03&created_at.rel=in
    #   GET /users?created_at[]=2020-01-01&created_at[]=2020-01-03&created_at.rel=between
    module Filterable
      extend ActiveSupport::Concern

      included do
        class_attribute :filter_fields, default: []
        class_attribute :mapped_filter_fields, default: []
      end

      class_methods do
        # @param keys [Array<Symbol,String,Hash>]
        # @param mapped_keys [Hash<Symbol,String>]
        def filterable_by(*keys, **mapped_keys)
          self.filter_fields = keys
          self.mapped_filter_fields = mapped_keys.to_a
        end
      end

      # @param scope [ActiveRecord::Relation]
      # @param filter_conditions [Array<Hash>]
      # @param filter_conditions[:field] [Symbol,String]
      # @param filter_conditions[:value] [String,Integer,Array<String,Integer>]
      # @param filter_conditions[:relation] [String]
      # @return [ActiveRecord::Relation]
      def filter(scope, filter_conditions: filter_conditions(*filter_fields, *mapped_filter_fields))
        Boosted::Queries::Filter.call(scope, filter_conditions:)
      end

      # @param fields [Array<Symbol,String>]
      # @param mapped_fields [Array<Hash<Symbol,String>>]
      # @return [Array<Hash>]
      def filter_conditions(*fields)
        fields.filter_map do |filter_opt|
          field = filter_name(filter_opt)

          next if filter_value(filter_opt).blank? && %w[is_null is_not_null].exclude?(filter_rel_value(filter_opt))

          {
            field:,
            value: filter_value(filter_opt),
            relation: filter_rel_value(filter_opt).presence || (filter_value(filter_opt).is_a?(Array) ? "in" : "=")
          }
        end
      end

      # @return [Array]
      def filter_fields
        self.class.filter_fields
      end

      # @return [Array]
      def mapped_filter_fields
        self.class.mapped_filter_fields
      end

      private

      def filter_name(filter)
        filter.is_a?(Array) ? filter.first : filter
      end

      def filter_mapped_name(filter)
        filter.is_a?(Array) ? filter.last : filter
      end

      def filter_value(filter)
        param_key = filter_mapped_name(filter)
        params[param_key]
      end

      def filter_rel_value(filter)
        param_key = filter_mapped_name(filter)
        params["#{param_key}.rel"]
      end
    end
  end
end
