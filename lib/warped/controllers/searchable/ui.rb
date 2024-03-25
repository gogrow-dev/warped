# frozen_string_literal: true

require "active_support/concern"

module Warped
  module Controllers
    module Searchable
      module Ui
        extend ActiveSupport::Concern

        include Searchable

        included do
          helper_method :search_url_params
        end

        def search_url_params(**options)
          return options if search_term.blank?

          url_params = { search_param => search_term }
          url_params.merge!(options)
          url_params
        end
      end
    end
  end
end
