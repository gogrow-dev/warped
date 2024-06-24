# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/enumerable"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/core_ext/object/blank"

module Warped
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
    #   GET /users?accounts.kind=premium&accounts.kind.rel=neq
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
    #     filterable_by :name, :created_at, 'accounts.kind' => { alias_name: 'kind' }
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
    # @see Warped::Queries::Filter::RELATIONS
    # To see the full list of operands, check the +Warped::Queries::Filter::RELATIONS+ constant.
    #
    # To use the operands, you must pass a parameter appended with `.rel`, and the value of a valid operand.
    #
    # Example requests:
    #   GET /users?created_at=2020-01-01&created_at.rel=gt
    #   GET /users?created_at=2020-01-01&created_at.rel=lt
    #   GET /users?created_at=2020-01-01&created_at.rel=neq
    #
    # When the operand relation requires multiple values, like +in+, +not_in+, or +between+,
    # you can pass an array of values.
    #
    # Example requests:
    #   GET /users?created_at[]=2020-01-01&created_at[]=2020-01-03&created_at.rel=in
    #   GET /users?created_at[]=2020-01-01&created_at[]=2020-01-03&created_at.rel=between
    #
    # Setting types and casting:
    # By default, the filter values are cast to strings. If you want to cast the values to a specific type,
    # and validate that the values are of the correct type, you can pass the kind of the filter to
    # the +filterable_by+ method.
    #
    # Example:
    #
    #   class UsersController < ApplicationController
    #     include Filterable
    #
    #     filterable_by :name, :created_at, 'accounts.active' => { kind: :integer, alias_name: 'active' }
    #
    #     def index
    #       scope = filter(User.joins(:account))
    #       render json: scope
    #     end
    #   end
    #
    # Example requests:
    #   GET /users?active=1
    #
    # The +kind+ parameter will be cast to an integer.
    # If the value is not an integer, an error will be raised, and the response will be a 400 Bad Request.
    #
    # In order to change the error message, you can rescue from the +Filter::ValueError+ exception, or
    # override the +render_invalid_filter_value+ method.
    #
    #   def render_invalid_filter_value(exception)
    #     render action_name, status: :bad_request
    #   end
    #
    module Filterable
      extend ActiveSupport::Concern

      included do
        class_attribute :filters, default: []
        class_attribute :strict_filtering, default: false

        helper_method :current_action_filters, :current_action_filter_values
      end

      class_methods do
        # @param keys [Array<Symbol,String,Hash>]
        # @param mapped_keys [Hash<Symbol,String>]
        def filterable_by(*keys, strict: nil, **mapped_keys)
          self.strict_filtering = strict unless strict.nil?

          self.filters = keys.map do |field|
            Warped::Filter.build(nil, field, strict:)
          end

          complex_filters = mapped_keys.with_indifferent_access

          self.filters += complex_filters.map do |field_name, opts|
            kind = opts[:kind]
            alias_name = opts[:alias_name]

            Warped::Filter.build(kind, field_name, alias_name:, strict:)
          end
        end
      end

      # @param scope [ActiveRecord::Relation]
      # @param filter_conditions [Array<Warped::Filter::Base>|nil]
      # @return [ActiveRecord::Relation]
      def filter(scope, filter_conditions: nil)
        action_filters = filter_conditions.presence || filters
        @current_action_filters = action_filters
        @current_action_filter_values = parse_filter_params

        Warped::Queries::Filter.call(scope, filter_conditions: current_action_filter_values.map(&:to_h))
      end

      # @return [Array<Hash>]
      def parse_filter_params
        current_action_filters.filter_map do |filter|
          raw_value = params[filter.parameter_name]
          raw_relation = params["#{filter.parameter_name}.rel"]

          filter_value = filter.class::Value.new(filter, raw_relation.presence || "eq", raw_value.presence)

          next if filter_value.empty?

          filter_value
        end
      end

      # @return [Array<Warped::Filter::Base>]
      def current_action_filters
        @current_action_filters ||= []
      end

      # @return [Array<Warped::Filter::Base::Value>]
      def current_action_filter_values
        @current_action_filter_values ||= []
      end
    end
  end
end
