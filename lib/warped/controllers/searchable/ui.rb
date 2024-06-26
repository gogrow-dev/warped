# frozen_string_literal: true

require "active_support/concern"

module Warped
  module Controllers
    module Searchable
      module Ui
        extend ActiveSupport::Concern

        include Searchable

        included do
          helper_method :searched?, :search_url_params
        end

        # @see Searchable#search
        def search(...)
          @searched = true

          super
        end

        # @return [Boolean] Whether the current action is searched.
        def searched?
          @searched ||= false
        end

        # @return [Hash] The search_url_params
        def search_url_params(**options)
          url_params = { search_param => search_term }
          url_params.merge!(options)
        end
      end
    end
  end
end
