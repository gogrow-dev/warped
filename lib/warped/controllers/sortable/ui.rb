# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/object/blank"

module Warped
  module Controllers
    module Sortable
      module Ui
        extend ActiveSupport::Concern

        include Sortable

        included do
          helper_method :attribute_name, :sorted?, :sorted_field?, :sortable_field?, :sort_url_params
        end

        # @see Sortable#sort
        def sort(...)
          @sorted = true

          super
        end

        # @param parameter_name [String]
        # @return [Boolean]
        def sorted_field?(parameter_name)
          current_action_sort_value.parameter_name == parameter_name.to_s
        end

        # @param parameter_name [String]
        # @return [Boolean] Whether the parameter_name is sortable.
        def sortable_field?(parameter_name)
          current_action_sorts.any? { |sort| sort.parameter_name == parameter_name.to_s }
        end

        # @return [Boolean] Whether the current action is sorted.
        def sorted?
          @sorted ||= false
        end

        # @return [Hash] The sort_url_params
        def sort_url_params(**options)
          url_params = {
            sort_key: current_action_sort_value.parameter_name,
            sort_direction: current_action_sort_value.direction
          }
          url_params.merge!(options)
        end
      end
    end
  end
end
