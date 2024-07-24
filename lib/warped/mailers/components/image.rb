# frozen_string_literal: true

module Warped
  module Mailers
    class Image < Base
      variant do
        base { "display: block; height: auto;" }

        size do
          sm { "max-width: 320px" }
          md { "max-width: 480px" }
          lg { "max-width: 640px" }
          full { "max-width: 100%" }
        end
      end

      def initialize(src, size: :full, alt: nil)
        super()
        @src = src
        @size = size
        @alt = alt
      end

      def template
        style = style(size:)

        tag.img(src:, alt:, style:)
      end

      private

      attr_reader :src, :size, :alt
    end
  end
end
