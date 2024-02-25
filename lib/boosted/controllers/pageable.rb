# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"

module Boosted
  module Controllers
    # Provides pagination functionality for controllers.
    #
    # Example usage:
    #
    #   class UsersController < ApplicationController
    #     include Pageable
    #
    #     def index
    #       scope = paginate(User.all)
    #       render json: scope, root: :users, meta: page_info
    #     end
    #   end
    #
    # Example requests:
    #   GET /users?page=1&per_page=10
    #   GET /users?page=2&per_page=50
    #
    # The +per_page+ parameter is optional. If not provided, the default value will be used.
    #
    # The default value can be set at a controller level using the +default_per_page+ class attribute.
    # Example:
    #   class UsersController < ApplicationController
    #     include Pageable
    #
    #     self.default_per_page = 50
    #
    #     def index
    #       scope = paginate(User.all)
    #       render json: scope, root: :users, meta: page_info
    #     end
    #   end
    #
    # Or by overriding the +default_per_page+ controller instance method.
    # Example:
    #   class UsersController < ApplicationController
    #     include Pageable
    #
    #     def index
    #       scope = paginate(User.all)
    #       render json: scope, root: :users, meta: page_info
    #     end
    #
    #     private
    #
    #     def default_per_page
    #       50
    #     end
    #   end
    #
    # The +per_page+ value can also be set at action level, by passing the +per_page+ parameter to
    # the +paginate+ method.
    # Example:
    #   class UsersController < ApplicationController
    #     include Pageable
    #
    #     def index
    #       scope = paginate(User.all, per_page: 50)
    #       render json: scope, root: :users, meta: page_info
    #     end
    #
    #     def other_index
    #       # The default per_page value is used.
    #       scope = paginate(User.all)
    #       render json: scope, root: :users, meta: page_info
    #     end
    #   end
    #
    # The pagination metadata can be accessed by calling the +page_info+ method.
    # It includes the following keys:
    # - +total_count+: The total number of records in the collection.
    # - +total_pages+: The total number of pages.
    # - +next_page+: The next page number.
    # - +prev_page+: The previous page number.
    # - +page+: The current page number.
    # - +per_page+: The number of records per page.
    # *Warning*: The +page_info+ method will raise an +ArgumentError+ if the method +paginate+ was not
    # called within the action.
    module Pageable
      extend ActiveSupport::Concern

      included do
        class_attribute :default_per_page, default: Queries::Paginate::DEFAULT_PER_PAGE
      end

      # Paginates the given scope.
      #
      # @param scope [ActiveRecord::Relation] The scope to be paginated.
      # @param page [String,Integer,nil] The page number.
      # @param per_page [String,Integer,nil] The number of records per page.
      # @return [ActiveRecord::Relation] The paginated scope.
      def paginate(scope, page: self.page, per_page: self.per_page)
        @page_info, paginated_scope = Queries::Paginate.call(scope, page:, per_page:)
        paginated_scope
      end

      # Retrieves the page number from the request parameters.
      #
      # @return [String,nil] The page number if present, otherwise nil.
      def page
        params[:page]&.to_i || 1
      end

      # Retrieves the number of records per page from the request parameters or defaults to the
      # controller's default value.
      #
      # @return [String,Integer] The number of records per page.
      def per_page
        params[:per_page].presence || self.class.default_per_page
      end

      # Retrieves pagination metadata.
      #
      # @return [Hash] Metadata about the pagination.
      # @raise [ArgumentError] If pagination was not performed.
      # @see Boosted::Queries::Paginate#metadata
      def page_info
        return @page_info if @page_info.present?

        raise ActionController::BadRequest, "Pagination was not performed"
      end
    end
  end
end
