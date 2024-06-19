# frozen_string_literal: true

require "active_support/core_ext/object/blank"

module Warped
  class Sort
    class DirectionError < StandardError; end

    SORT_DIRECTIONS = %w[asc desc].freeze
    NULLS_SORT_DIRECTION = %w[asc_nulls_first asc_nulls_last desc_nulls_first desc_nulls_last].freeze

    attr_accessor :name, :alias_name

    def self.directions
      @directions ||= SORT_DIRECTIONS + NULLS_SORT_DIRECTION
    end

    def initialize(name, alias_name: nil)
      raise ArgumentError, "name cannot be nil" if name.nil?

      @name = name.to_s
      @alias_name = alias_name&.to_s
    end

    def parameter_name
      alias_name.presence || name
    end

    def direction!(direction)
      raise DirectionError, "Invalid direction: #{direction}" unless valid_direction?(direction.to_s)

      direction.to_s
    end

    def opposite_direction(direction)
      opposite_directions[direction]
    end

    private

    def valid_direction?(relation)
      self.class.directions.include?(relation.to_s)
    end

    def opposite_directions
      @opposite_directions ||= {
        "asc" => "desc",
        "desc" => "asc",
        "asc_nulls_first" => "desc_nulls_last",
        "asc_nulls_last" => "desc_nulls_first",
        "desc_nulls_first" => "asc_nulls_last",
        "desc_nulls_last" => "asc_nulls_first"
      }.freeze
    end
  end
end
