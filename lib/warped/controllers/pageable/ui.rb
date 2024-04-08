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

        def paginate_url_params(**options)
          url_params = { page:, per_page: }
          url_params.merge!(options)
          url_params
        end

        def pagination
          super.tap do |hsh|
            hsh[:series] = series(hsh[:page], hsh[:total_pages])
          end
        end

        def paginate(...)
          @paginated = true

          super
        end

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
          return [] if total_pages.zero?
          return ["1"] if total_pages == 1

          if total_pages <= 9
            (1..(page - 1)).to_a + [page.to_s] + ((page + 1)..total_pages).to_a
          else
            [1, :gap, page - 2, page - 1, page.to_s, page + 1, page + 2, :gap, total_pages]
          end
        end
      end
    end
  end
end
