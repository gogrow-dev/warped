# frozen_string_literal: true

module Warped
  module Filter
    class Factory
      TYPES = %i[string integer float decimal date time date_time boolean].freeze

      def self.build(kind, *args, **kwargs)
        new(kind).build(*args, **kwargs)
      end

      def initialize(kind = nil)
        @kind = kind
        validate_kind!
      end

      def build(*args, **kwargs)
        filter_class.new(*args, **kwargs)
      end

      private

      attr_reader :kind

      def validate_kind!
        return if kind.nil?

        raise ArgumentError, "#{kind} is not a valid filter type" unless TYPES.include?(kind)
      end

      def filter_class
        return Base if kind.nil?

        Filter.const_get(kind.to_s.camelize)
      end
    end
  end
end
