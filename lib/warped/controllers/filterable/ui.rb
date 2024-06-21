# frozen_string_literal: true

require "active_support/concern"

module Warped
  module Controllers
    module Filterable
      module Ui
        extend ActiveSupport::Concern
        include Filterable

        included do
          helper_method :filters, :filtered?, :filter_url_params, :filterable_by
        end

        # @see Filterable#filter
        def filter(...)
          @filtered = true

          super
        end

        # @return [Boolean] Whether the current action is filtered.
        def filtered?
          @filtered ||= false
        end

        # @return [Hash] The filters for the current action.
        def filter_url_params(**options)
          url_params = {}
          current_action_filter_values.each_with_object(url_params) do |filter_value, hsh|
            if filter_value.value.is_a?(Array)
              filter_value.value.each { |value| hsh["#{filter_value.parameter_name}[]"] = value }
            else
              hsh[filter_value.parameter_name] = filter_value.value
            end

            hsh["#{filter_value.parameter_name}.rel"] = filter_value.relation
          end

          url_params.merge!(options)
        end
      end
    end
  end
end
