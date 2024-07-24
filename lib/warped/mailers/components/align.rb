# frozen_string_literal: true

module Warped
  module Mailers
    class Align < Base
      variant do
        base { ["text-align: #{@align}"] }
      end

      def initialize(align: :left)
        super()
        @align = align
        raise ArgumentError, "Invalid alignment: #{align}" unless %i[left center right].include?(align)
      end

      def template
        tag.div(content, style:)
      end
    end
  end
end
