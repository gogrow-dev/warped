# frozen_string_literal: true

require "active_support/concern"

module Warped
  module Controllers
    module Tabulatable
      module Ui
        extend ActiveSupport::Concern

        include Tabulatable
        include Filterable::Ui
        include Pageable::Ui
        include Searchable::Ui
        include Sortable::Ui

        included do
          helper_method :tabulation, :tabulate_url_params, :tabulate_query
        end

        # @return [Hash]
        def tabulation
          {
            filters:,
            current_filters:,
            sorts:,
            current_sorts:,
            search_term:,
            search_param:,
            pagination:
          }
        end

        # @param options [Hash] Additional hash of options to include in the tabulation url_params
        # @return [Hash] The tabulation url_params
        def tabulate_url_params(**options)
          base = paginate_url_params
          base.merge!(search_url_params)
          base.merge!(sort_url_params)
          base.merge!(filter_url_params)
          base.merge!(options)

          base.tap(&:compact_blank!)
        end

        # @param options [Hash] Additional hash of options to include in the tabulation query
        # @return [String] The tabulation query string
        def tabulate_query(**options)
          tabulate_url_params(**options).to_query
        end
      end
    end
  end
end
