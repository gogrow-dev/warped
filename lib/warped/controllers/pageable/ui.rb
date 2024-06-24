# frozen_string_literal: true

require "active_support/concern"

module Warped
  module Controllers
    module Pageable
      module Ui
        extend ActiveSupport::Concern

        include Pageable

        included do
          helper_method :pagination, :paginated?, :paginate_url_params
        end

        # @return [Hash] The paginate_url_params
        def paginate_url_params(**options)
          url_params = { page:, per_page: }
          url_params.merge!(options)
        end

        # @see Pageable#pagination
        # @return [Hash]
        def pagination
          super.tap do |hsh|
            hsh[:series] = series(hsh[:page], hsh[:total_pages])
          end
        end

        # @see Pageable#paginate
        def paginate(...)
          @paginated = true

          super
        end

        # @return [Boolean] Whether the current action is paginated.
        def paginated?
          @paginated ||= false
        end

        private

        # @param page [Integer]
        # @param total_pages [Integer]
        # @return [Array]
        #   the series method returns an array of page numbers and :gap symbols
        #   the current page is a string, the others are integers
        #   series example: [1, :gap, 7, 8, "9", 10, 11, :gap, 36]
        def series(page, total_pages)
          current_page = [page, total_pages].min
          return [] if total_pages.zero?
          return ["1"] if total_pages == 1

          if total_pages <= 9
            (1..(current_page - 1)).to_a + [current_page.to_s] + ((current_page + 1)..total_pages).to_a
          elsif current_page <= 5
            [*(1..6).to_a.map { |i| i == page ? i.to_s : i }, :gap, total_pages]
          elsif current_page >= total_pages - 4
            [1, :gap, *(total_pages - 5..total_pages).to_a.map { |i| i == current_page ? i.to_s : i }]
          else
            [1, :gap, current_page - 2, current_page - 1, current_page.to_s, current_page + 1, current_page + 2, :gap,
             total_pages]
          end
        end
      end
    end
  end
end
