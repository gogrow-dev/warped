# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/object/blank"

module Warped
  module Controllers
    # Provides functionality for sorting records from an +ActiveRecord::Relation+ in a controller.
    #
    # Example usage:
    #
    #   class UsersController < ApplicationController
    #     include Sortable
    #
    #     sortable_by :name, :created_at, 'accounts.kind'
    #
    #     def index
    #       scope = sort(User.joins(:account))
    #       render json: scope
    #     end
    #   end
    #
    # Example requests:
    #   GET /users?sort_key=name
    #   GET /users?sort_key=name&sort_direction=asc_nulls_first
    #   GET /users?sort_key=created_at&sort_direction=asc
    #
    # Renaming sort keys:
    #
    # In some cases, you may not want to expose the actual column names to the client.
    # In such cases, you can rename the sort keys by passing a hash to the +sortable_by+ method.
    #
    # Example:
    #
    #   class UsersController < ApplicationController
    #     include Sortable
    #
    #     sortable_by :name, :created_at, 'accounts.referrals_count' => { alias_name: 'referrals' }
    #
    #     def index
    #       scope = sort(User.joins(:account))
    #       render json: scope
    #     end
    #   end
    #
    # Example requests:
    #   GET /users?sort_key=referrals&sort_direction=asc
    #
    # The +sort_key+ and +sort_direction+ parameters are optional. If not provided, the default sort key and direction
    # will be used.
    #
    # The default sort key and sort direction can be set at a controller level using the +default_sort_direction+ and
    # +default_sort_key+ class attributes.
    module Sortable
      extend ActiveSupport::Concern

      included do
        class_attribute :sorts, default: []
        class_attribute :default_sort, default: Sort.new("id")
        class_attribute :default_sort_direction, default: "desc"

        attr_reader :current_action_sorts

        helper_method :current_action_sorts, :current_action_sort_value, :default_sort, :default_sort_direction

        rescue_from Sort::DirectionError, with: :render_invalid_sort_direction
      end

      class_methods do
        # @param keys [Array<Symbol,String>]
        # @param mapped_keys [Hash<Symbol,String>]
        def sortable_by(*keys, **mapped_keys)
          self.sorts = keys.map do |field|
            Warped::Sort.new(field)
          end

          self.sorts += mapped_keys.map do |field, opts|
            Warped::Sort.new(field, alias_name: opts[:alias_name])
          end

          return if self.sorts.any? { |sort| sort.name == default_sort.name }

          self.sorts.push(default_sort)
        end
      end

      # @param scope [ActiveRecord::Relation] The scope to sort.
      # @param sort_key [String, Symbol] The sort key.
      # @param sort_direction [String, Symbol] The sort direction.
      # @return [ActiveRecord::Relation]
      def sort(scope, sort_conditions: nil)
        action_sorts = sort_conditions.presence || sorts
        @current_action_sorts = action_sorts

        Queries::Sort.call(scope, sort_key: current_action_sort_value.name,
                                  sort_direction: current_action_sort_value.direction)
      end

      # @return [String] The sort direction.
      def current_action_sort_value
        @current_action_sort_value ||= begin
          sort_obj = current_action_sorts.find do |sort|
            params[:sort_key] == sort.parameter_name
          end

          if sort_obj.present?
            Sort::Value.new(sort_obj, params[:sort_direction] || default_sort_direction)
          else
            Sort::Value.new(default_sort, default_sort_direction)
          end
        end
      end

      protected

      def render_invalid_sort_direction(exception)
        render json: { error: exception.message }, status: :bad_request
      end

      private

      # @return [Warped::Sort] The current sort object.
      def current_sort
        @current_sort ||= begin
          sort_obj = sorts.find do |sort|
            params[:sort_key] == sort.parameter_name
          end

          sort_obj.presence || Warped::Sort.new(default_sort_key)
        end
      end
    end
  end
end
