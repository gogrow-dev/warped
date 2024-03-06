# frozen_string_literal: true

module Warped
  module Emails
    class Link < Base
      variant do
        base { ["text-decoration: underline"] }

        size do
          xs { ["font-size: 11px", "line-height: 16px"] }
          sm { ["font-size: 13px", "line-height: 16px"] }
          md { ["font-size: 16px", "line-height: 24px"] }
          lg { ["font-size: 19px", "line-height: 24px"] }
        end

        color do
          regular     { "color: #414750" }
          placeholder { "color: #8B939F" }
          info        { "color: #1C51A4" }
        end

        display do
          block  { "display: block" }
          inline { "display: inline" }
        end
      end

      default_variant size: :md, color: :info, display: :inline

      def initialize(text = nil, href, size: :md, color: :regular, display: :inline)
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
