# frozen_string_literal: true

require "boosted/services/base"

module Boosted
  module Queries
    ##
    # Paginate a scope
    #
    # This class provides a way to paginate a scope and return the metadata.
    #
    # @example
    #   Boosted::Queries::Paginate.call(User.all, page: 2, per_page: 10)
    #   # => [{ total_count: 100, total_pages: 10, next_page: 3, prev_page: 1, page: 2, per_page: 10 }, <ActiveRecord::Relation [...]>]
    #
    # @see MAX_PER_PAGE
    # @see DEFAULT_PER_PAGE
    # To see the maximum number of records per page and the default number of records per page,
    # check the +MAX_PER_PAGE+ and +DEFAULT_PER_PAGE+ constants.
    class Paginate
      MAX_PER_PAGE = 100
      DEFAULT_PER_PAGE = 10

      # @param scope [ActiveRecord::Relation] the scope to paginate
      # @param page [Integer] the page number
      # @param per_page [Integer] the number of records per page
      # @return [Array<Hash, ActiveRecord::Relation>] the metadata and the paginated scope
      def self.call(scope, page: nil, per_page: nil)
        new(scope, page:, per_page:).call
      end

      # @param scope [ActiveRecord::Relation] the scope to paginate
      # @param page [Integer] the page number
      # @param per_page [Integer] the number of records per page
      # @return [Array<Hash, ActiveRecord::Relation>] the metadata and the paginated scope
      def initialize(scope, page: nil, per_page: nil)
        super()
        @scope = scope
        @page = page
        @per_page = per_page
      end

      def call
        offset = (page - 1) * per_page
        paginated_scope = scope.limit(per_page).offset(offset)

        [metadata(scope), paginated_scope]
      end

      private

      attr_reader :scope

      def page
        @page.present? ? @page.to_i : 1
      end

      def per_page
        @per_page.present? ? [@per_page.to_i, MAX_PER_PAGE].min : DEFAULT_PER_PAGE
      end

      def collection_count(scope)
        if scope.group_values.empty?
          scope.count(:all)
        else
          sql = Arel.star.count.over(Arel::Nodes::Grouping.new([]))
          scope.unscope(:order).pick(sql).to_i
        end
      end

      def metadata(scope)
        total_count = collection_count(scope)
        total_pages = pages(total_count, per_page)
        next_page = next_page(page, total_pages)
        prev_page = prev_page(page)

        {
          total_count:,
          total_pages:,
          next_page:,
          prev_page:,
          page:,
          per_page:
        }
      end

      def pages(count, per_page)
        (count.to_f / per_page).ceil
      end

      def next_page(page, pages)
        page < pages ? page + 1 : nil
      end

      def prev_page(page)
        page > 1 ? page - 1 : nil
      end
    end
  end
end
