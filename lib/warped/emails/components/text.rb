# frozen_string_literal: true

module Warped
  module Emails
    class Text < Base
      variant do
        base { "font-family: Arial, sans-serif" }

        size do
          sm { "font-size: 12px" }
          md { "font-size: 14px" }
          lg { "font-size: 16px" }
        end

        color do
          regular { "color: #333" }
          muted { "color: #666666" }
        end

        align do
          left { "text-align: left" }
          right { "text-align: right" }
          center { "text-align: center" }
        end

        weight do
          light { "font-weight: lighter" }
          regular { "font-weight: normal" }
          bold { "font-weight: bold" }
        end
      end

      default_variant size: :md, color: :regular, weight: :regular, align: :left

      def initialize(text = nil, size: :md, color: :regular, weight: :regular, align: :left)
        super()
        @text = text
        @size = size
        @color = color
        @weight = weight
        @align = align
      end

      def text
        content.presence || @text
      end

      def template(&)
        style = style(size:, color:, weight:, align:)

        tag.p(text, style:)
      end

      private

      attr_reader :size, :color, :weight, :align
    end
  end
end
