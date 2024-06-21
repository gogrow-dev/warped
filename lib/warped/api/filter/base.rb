# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/string/inflections"

module Warped
  module Filter
    class Base
      RELATIONS = %w[eq neq gt gte lt lte between in not_in starts_with ends_with contains is_null is_not_null].freeze

      attr_reader :name, :alias_name, :options

      delegate :[], to: :options

      # @return [Symbol, nil] The filter kind.
      def self.kind
        filter_type = name.demodulize.underscore.to_sym

        filter_type == :filter ? nil : filter_type
      end

      # @param name [String] The name of the filter.
      # @param alias_name [String] The alias name of the filter, used for renaming the filter key in the URL params
      # @param options [Hash] The filter options.
      def initialize(name, alias_name: nil, **options)
        raise ArgumentError, "name cannot be nil" if name.nil?

        @name = name.to_s
        @alias_name = alias_name&.to_s
        @options = options
      end

      # @return [Symbol, nil] The filter kind.
      def kind
        self.class.kind
      end

      # @return [Array<String>] The valid filter relations.
      def relations
        self.class::RELATIONS
      end

      # @param relation [String] The filter relation.
      def cast!(value)
        value
      end

      # @param relation [String] The validated filter relation.
      def relation!(relation)
        raise RelationError, "Invalid relation: #{relation}" unless valid_relation?(relation)

        relation
      end

      # @return [String] The name to use in the URL params.
      def parameter_name
        alias_name.presence || name
      end

      # @return [String] The HTML input type.
      def html_type
        raise NotImplementedError, "#{self.class.name}#html_type not implemented"
      end

      private

      def valid_relation?(relation)
        relations.include?(relation.to_s)
      end
    end
  end
end
