# frozen_string_literal: true

module Warped
  module Emails
    class Heading < Base
      variant do
        base do
          ["font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif",
           "font-weight: 400",
           "color: #333"]
        end

        level do
          h1 { "font-size: 32px; line-height: 40px" }
          h2 { "font-size: 24px; line-height: 32px" }
          h3 { "font-size: 20px; line-height: 28px" }
          h4 { "font-size: 16px; line-height: 24px" }
          h5 { "font-size: 14px; line-height: 20px" }
          h6 { "font-size: 12px; line-height: 16px" }
        end

        align do
          left   { "text-align: left" }
          center { "text-align: center" }
          right  { "text-align: right" }
        end
      end

      default_variant level: :h1, align: :center

      def initialize(text = nil, level: :h1, align: :center)
        super()
        @text = text
        @level = level
        @align = align
      end

      def text
        content.presence || @text
      end

      def template
        style = style(level:, align:)

        tag.send(level, text, style:)
      end

      private

      attr_reader :level, :align
    end
  end
end
