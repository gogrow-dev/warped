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

      def self.kind
        filter_type = name.demodulize.underscore.to_sym

        filter_type == :filter ? nil : filter_type
      end

      def initialize(name, alias_name: nil, **options)
        raise ArgumentError, "name cannot be nil" if name.nil?

        @name = name.to_s
        @alias_name = alias_name&.to_s
        @options = options
      end

      def kind
        self.class.kind
      end

      def relations
        self.class::RELATIONS
      end

      def cast!(value)
        value
      end

      def relation!(relation)
        raise RelationError, "Invalid relation: #{relation}" unless valid_relation?(relation)

        relation
      end

      def parameter_name
        alias_name.presence || name
      end

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
