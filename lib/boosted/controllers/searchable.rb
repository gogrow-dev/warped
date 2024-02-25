# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"

module Boosted
  module Controllers
    # Provides functionality for searching records from an ActiveRecord::Relation.
    #
    # Example usage:
    #   class User < ApplicationRecord
    #     scope :search, ->(term) { where('name ILIKE ?', "%#{term}%") }
    #   end
    #
    #   class UsersController < ApplicationController
    #     include Searchable
    #
    #     def index
    #       scope = search(User.all)
    #       render json: scope
    #     end
    #   end
    #
    # Example requests:
    #   GET /users?q=John
    #   GET /users?q=John%20Doe
    #
    # There are cases where the search scope is not called +search+.
    # In such cases, you can use the +searchable_by+ method to override the search scope.
    #
    # Example:
    #   class User < ApplicationRecord
    #     scope :search_case_sensitive, ->(term) { where('name LIKE ?', "%#{term}%") }
    #   end
    #
    #   class UsersController < ApplicationController
    #     include Searchable
    #
    #     searchable_by :search_case_sensitive
    #
    #     def index
    #       scope = search(User.all)
    #       render json: scope
    #     end
    #   end
    #
    # When only overriding the search scope for a single action, you can pass the scope name as an argument to
    # the +search+ method.
    # Example:
    #   class UsersController < ApplicationController
    #     include Searchable
    #
    #     def index
    #       # The default search scope name is overridden.
    #       # runs User.all.search_case_sensitive(search_term)
    #       scope = search(User.all, model_search_scope: :search_case_sensitive)
    #       render json: scope
    #     end
    #
    #     def other_index
    #       # The default search scope name is used.
    #       # runs User.all.search(search_term)
    #       scope = search(User.all)
    #       render json: scope
    #     end
    #   end
    #
    # In addition, you can override the search term parameter name for the entire controller by implementing
    # the +search_param+ method.
    #
    # Example:
    #   class UsersController < ApplicationController
    #     include Searchable
    #
    #     def index
    #       scope = search(User.all)
    #       render json: scope
    #     end
    #
    #     private
    #
    #     def search_param
    #       :term
    #     end
    #   end
    #
    # Or you can override the search term parameter name for a single action by passing the parameter name as
    # an argument to the +search_term+ method.
    #
    # Example:
    #   class UsersController < ApplicationController
    #     include Searchable
    #
    #     def index
    #       # The default search term parameter name (+q+) is overridden.
    #       # GET /users?term=John
    #       scope = search(User.all, search_term: params[:term])
    #       render json: scope
    #     end
    #
    #     def other_index
    #       # The default search term parameter name (+q+) is used.
    #       # GET /other_users?q=John
    #       scope = search(User.all)
    #       render json: scope
    #     end
    #   end
    #
    # Example requests:
    #   GET /users?term=John
    #   GET /other_users?q=John%20Doe
    module Searchable
      extend ActiveSupport::Concern

      included do
        class_attribute :model_search_scope, default: :search
        class_attribute :search_param, default: :q
      end

      class_methods do
        # Sets the search scope.
        #
        # @param scope [Symbol] The name of the search scope.
        def searchable_by(scope, param: :q)
          self.model_search_scope = scope
          self.search_param = param
        end
      end

      # Searches records based on the provided scope and search term.
      #
      # @param scope [ActiveRecord::Relation] The scope to search within.
      # @param search_term [String] The search term.
      # @param model_search_scope [Symbol] The name of the search scope.
      # @return [ActiveRecord::Relation] The result of the search.
      def search(scope, search_term: self.search_term, model_search_scope: self.model_search_scope)
        Queries::Search.call(scope, search_term:, model_search_scope:)
      end

      # Retrieves the search term from the request parameters.
      #
      # @return [String, nil] The search term if present, otherwise nil.
      def search_term
        params[search_param]&.strip
      end

      # Returns the name of the parameter used for searching.
      #
      # @return [Symbol] The search parameter name.
      def search_param
        self.class.search_param
      end

      # Returns the name of the model's search scope.
      #
      # @return [Symbol] The name of the model's search scope.
      def model_search_scope
        self.class.model_search_scope
      end
    end
  end
end
