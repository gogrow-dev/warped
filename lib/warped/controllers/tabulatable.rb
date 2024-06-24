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
    #     tabulatable_by :email, :age, 'posts.created_at', 'posts.id' => { alias_name: 'post_id', kind: :integer }
    #
    #     def index
    #       users = User.left_joins(:posts).group(:id)
    #       users = tabulate(users)
    #       render json: users, meta: tabulation
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
    #     tabulatable_by :title, :content, :created_at, user: { alias_name: 'users.name' }
    #     filterable_by :created_at, user: { alias_name: 'users.name' }
    #
    #     def index
    #       posts = Post.left_joins(:user).group(:id)
    #       posts = tabulate(posts)
    #       render json: posts, meta: tabulation
    #     end
    #   end
    module Tabulatable
      extend ActiveSupport::Concern

      include Filterable
      include Sortable
      include Searchable
      include Pageable

      included do
        class_attribute :tabulate_fields, default: []
        class_attribute :mapped_tabulate_fields, default: {}
      end

      class_methods do
        def tabulatable_by(*keys, **mapped_keys)
          filterable_by(*keys, **mapped_keys) if filters.empty?
          sortable_by(*keys, **mapped_keys) if sorts.empty?
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
    end
  end
end
