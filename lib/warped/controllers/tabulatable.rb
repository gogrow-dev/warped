# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/class/attribute"

module Warped
  module Controllers
    # Provides functionality for filtering, sorting, searching, and paginating records
    # from an +ActiveRecord::Relation+ in a controller.
    #
    # Example usage:
    #
    #   class UsersController < ApplicationController
    #     include Tabulatable
    #
    #     tabulatable_by :name, :email, :age, 'posts.created_at', 'posts.id' => 'post_id'
    #
    #     def index
    #       users = User.left_joins(:posts).group(:id)
    #       users = tabulate(users)
    #       render json: users, meta: tabulate_info
    #     end
    #   end
    #
    # There are cases where not all fields should be filterable or sortable.
    # In such cases, you can use the `filterable_by` and `sortable_by` methods to
    # override the tabulate fields.
    #
    # Example:
    #
    #   class PostsController < ApplicationController
    #     include Tabulatable
    #
    #     tabulatable_by :title, :content, :created_at, user: 'users.name'
    #     filterable_by :created_at, user: 'users.name'
    #
    #     def index
    #       posts = Post.left_joins(:user).group(:id)
    #       posts = tabulate(posts)
    #       render json: posts, meta: tabulate_info
    #     end
    #   end
    module Tabulatable
      extend ActiveSupport::Concern

      included do
        include Filterable
        include Sortable
        include Searchable
        include Pageable

        class_attribute :tabulate_fields, default: []
        class_attribute :mapped_tabulate_fields, default: []
      end

      class_methods do
        def tabulatable_by(*keys, **mapped_keys)
          self.tabulate_fields = keys
          self.mapped_tabulate_fields = mapped_keys.to_a

          filterable_by(*keys, **mapped_keys) if filter_fields.empty? && mapped_filter_fields.empty?
          sortable_by(*keys, **mapped_keys) if sort_fields.empty? && mapped_sort_fields.empty?
        end
      end

      # @param scope [ActiveRecord::Relation]
      # @return [ActiveRecord::Relation]
      # @see Filterable#filter
      # @see Sortable#sort
      # @see Searchable#search
      # @see Pageable#paginate
      def tabulate(scope)
        scope = filter(scope)
        scope = search(scope)
        scope = sort(scope)
        paginate(scope)
      end

      # @return [Hash]
      def tabulate_info
        {
          filters: filter_conditions(*filter_fields, *mapped_filter_fields),
          sorts: sort_conditions(*sort_fields, *mapped_sort_fields),
          search_term:,
          search_param:,
          page_info:
        }
      end
    end
  end
end
