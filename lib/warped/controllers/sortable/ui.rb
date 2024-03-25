# frozen_string_literal: true

require "active_support/concern"

module Warped
  module Controllers
    module Sortable
      module Ui
        extend ActiveSupport::Concern

        include Sortable

        included do
          helper_method :sort_url_params
        end

        def sort_url_params(**options)
          url_params = { sort_key:, sort_direction: }
          url_params.merge!(options)
          url_params
        end

        def sorts
          sort_fields + mapped_sort_fields.keys
        end

        def current_sorts
          return [] unless params[:sort_key].present?

          mapped_sort_field_param = mapped_sort_fields.value?(params[:sort_key]) ? params[:sort_key] : nil
          sort_field_param = sort_fields.find do |field|
            field == params[:sort_key]
          end
          param_sort_key = mapped_sort_field_param.presence || sort_field_param.presence

          return [] unless param_sort_key.present?

          [
            {
              key: param_sort_key,
              value: sort_direction
            }
          ]
        end
      end
    end
  end
end
