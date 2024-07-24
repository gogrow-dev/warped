# frozen_string_literal: true

module Warped
  module Mailers
    class Text < Base
      variant do
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
          success     { "color: #60830D" }
          warning     { "color: #82620F" }
          error       { "color: #AB2816" }
        end

        align do
          left   { "text-align: left" }
          right  { "text-align: right" }
          center { "text-align: center" }
        end

        weight do
          regular  { "font-weight: 400" }
          bold     { "font-weight: 700" }
        end

        display do
          block  { "display: block" }
          inline { "display: inline" }
        end
      end

      default_variant size: :md, color: :regular, weight: :regular, display: :block

      def initialize(text = nil, size: nil, color: nil, weight: nil, align: nil, display: nil)
        super()
        @text = text
        @size = size
        @color = color
        @weight = weight
        @align = align
        @display = display
      end

      def text
        content.presence || @text
      end

      def template(&)
        style = style(size:, color:, weight:, align:, display:)

        tag.p(text, style:)
      end

      private

      attr_reader :size, :color, :weight, :align, :display
    end
  end
end
