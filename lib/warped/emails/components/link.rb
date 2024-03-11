# frozen_string_literal: true

module Warped
  module Emails
    class Link < Text
      variant do
        base { ["text-decoration: underline"] }
      end

      default_variant size: :md, color: :info, display: :inline

      def initialize(text = nil, href, size: nil, color: nil, display: nil)
        super()
        @text = text
        @href = href
        @size = size
        @color = color
        @display = display
      end

      def text
        content.presence || @text
      end

      def template
        style = style(size:, color:, display:)

        tag.a(text, href:, style:)
      end

      private

      attr_reader :href, :size, :color, :display
    end
  end
end
