# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"

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
    #     sortable_by :name, :created_at, 'accounts.referrals_count' => 'referrals'
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
        class_attribute :sort_fields, default: []
        class_attribute :mapped_sort_fields, default: {}
        class_attribute :default_sort_key, default: :id
        class_attribute :default_sort_direction, default: :desc
      end

      class_methods do
        # @param keys [Array<Symbol,String>]
        # @param mapped_keys [Hash<Symbol,String>]
        def sortable_by(*keys, **mapped_keys)
          self.sort_fields = keys.map(&:to_s)
          self.mapped_sort_fields = mapped_keys.with_indifferent_access
        end
      end

      # @param scope [ActiveRecord::Relation] The scope to sort.
      # @param sort_key [String, Symbol] The sort key.
      # @param sort_direction [String, Symbol] The sort direction.
      # @return [ActiveRecord::Relation]
      def sort(scope, sort_key: self.sort_key, sort_direction: self.sort_direction)
        return scope unless sort_key && sort_direction

        validate_sort_key!

        Queries::Sort.call(scope, sort_key:, sort_direction:)
      end

      protected

      # @return [Symbol] The sort direction.
      def sort_direction
        @sort_direction ||= params[:sort_direction] || default_sort_direction
      end

      def sort_key
        @sort_key ||= mapped_sort_fields.key(params[:sort_key]).presence ||
                      params[:sort_key] ||
                      default_sort_key.to_s
      end

      private

      def validate_sort_key!
        return if valid_sort_key?

        possible_values = sort_fields + mapped_sort_fields.values
        message = "Invalid sort key: #{sort_key}, must be one of #{possible_values}"
        raise ActionController::BadRequest, message
      end

      def valid_sort_key?
        sort_key == default_sort_key.to_s ||
          sort_fields.include?(sort_key) ||
          mapped_sort_fields[sort_key].present?
      end
    end
  end
end
