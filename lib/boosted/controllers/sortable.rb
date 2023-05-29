# frozen_string_literal: true

module Boosted
  module Controllers
    # Boosted::Controllers::Sortable concern to add sorting support to any endpoint
    #  class PostsController < ApplicationController
    #    include Boosted::Controllers::Sortable
    #    sortable_by :title, :content
    #  end
    #
    # Then in your request you can add the following params:
    #  GET /posts?title_sort=desc&content_sort=asc
    #
    # Filtering by associations is also possible:
    #  class Post < ApplicationRecord
    #    belongs_to :user
    #  end
    #
    #  class User < ApplicationRecord
    #    has_many :posts
    #  end
    #
    #  class PostsController < ApplicationController
    #    include Boosted::Controllers::Sortable
    #    sortable_by :title, :content, 'users.name'
    #  end
    #
    #  GET /posts?users.name_sort=desc&title_sort=asc
    module Sortable
      module ClassMethods
        def sortable_by(*args)
          str_args = args.map(&:to_s)

          define_method :sortable_by do
            @sortable_by ||= str_args
          end

          str_args
        end
      end

      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          attr_writer :sortable_by
        end
      end

      def sort(scope)
        return scope if sorting_params.empty?

        sorting_params.each do |sort, direction|
          column = sort.gsub(/_sort/, "")
          parsed_direction = direction == "desc" ? :desc : :asc

          scope = scope.order(column => parsed_direction)
        end

        scope
      end

      def sorting_params
        @sorting_params ||= request.parameters.select do |k, _|
          sortable_by.any? { |f| k.to_s.match?(/^#{f}_sort/) }
        end
      end
    end
  end
end
