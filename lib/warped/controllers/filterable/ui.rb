# frozen_string_literal: true

require "active_support/concern"

module Warped
  module Controllers
    module Filterable
      module Ui
        extend ActiveSupport::Concern
        include Filterable

        included do
          helper_method :filters, :current_filters, :filter_url_params
        end

        def filter_url_params(**options)
          url_params = {}
          current_filters.each_with_object(url_params) do |filter, hsh|
            hsh[filter[:name]] = filter[:value]
            hsh["#{filter[:name]}.rel"] = filter[:relation]
          end

          url_params.merge!(options)
          url_params
        end

        def filters
          filter_fields.concat(mapped_filter_fields).map do |field|
            {
              name: filter_mapped_name(field),
              value: filter_value(field),
              relation: filter_rel_value(field)
            }
          end
        end

        def current_filters
          filter_fields.concat(mapped_filter_fields).filter_map do |field|
            filter_value = filter_value(field)
            filter_rel_value = filter_rel_value(field)

            next if filter_value.blank? && %w[is_null is_not_null].exclude?(filter_rel_value)

            {
              name: filter_mapped_name(field),
              value: filter_value,
              relation: filter_rel_value
            }
          end
        end
      end
    end
  end
end