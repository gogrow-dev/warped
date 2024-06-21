# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "active_support/core_ext/module/delegation"

module Warped
  module Filter
    class Base
      class Value
        attr_reader :filter

        delegate :name, :alias_name, :parameter_name, :kind, to: :filter

        # @param filter [Warped::Filter::Base] The filter object
        # @param relation [String] The filter relation.
        # @param value [String] The filter value.
        def initialize(filter, relation, value)
          @filter = filter
          @relation = relation
          @value = value
        end

        # @return [String] The casted filter value.
        def value
          filter.cast!(@value)
        end

        # @return [String] The validated filter relation.
        def relation
          filter.relation!(@relation)
        end

        # @return [Boolean] Whether the filter is empty.
        def empty?
          value.blank? && !%w[is_null is_not_null].include?(relation)
        end

        def to_h
          {
            field: filter.name,
            relation:,
            value:
          }
        end

        # Some filters may need to be parsed/formatted differently for the HTML input value.
        # This method can be overridden in the filter value class to provide a different value.
        alias html_value value
      end
    end
  end
end
