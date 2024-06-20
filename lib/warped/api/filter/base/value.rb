# frozen_string_literal: true

require "active_support/core_ext/object/blank"
require "active_support/core_ext/module/delegation"

module Warped
  module Filter
    class Base
      class Value
        attr_reader :filter

        delegate :name, :alias_name, :parameter_name, :kind, to: :filter

        def initialize(filter, relation, value)
          @filter = filter
          @relation = relation
          @value = value
        end

        def value
          filter.cast!(@value)
        end

        def relation
          filter.relation!(@relation)
        end

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

        alias html_value value
      end
    end
  end
end
