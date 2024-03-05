# frozen_string_literal: true

module Warped
  module Emails
    class Link < Base
      variant do
        size do
          sm { "font-size: 12px" }
          md { "font-size: 14px" }
          lg { "font-size: 16px" }
        end

        color do
          regular { "color: #333" }
          muted { "color: #666666" }
        end
      end

      default_variant size: :md, color: :regular

      def initialize(text = nil, href, size: :md, color: :regular)
        super()
        @text = text
        @href = href
        @size = size
        @color = color
      end

      def text
        content.presence || @text
      end

      def template
        style = style(size:, color:)

        tag.a(text, href:, style:)
      end

      private

      attr_reader :href, :size, :color
    end
  end
end
