# frozen_string_literal: true

module Warped
  module Emails
    class Heading < Base
      variant do
        base { ["font-weight: 400"] }

        level do
          h1 { ["font-size: 45px", "line-height: 50px"] }
          h2 { ["font-size: 40px", "line-height: 45px"] }
          h3 { ["font-size: 35px", "line-height: 40px"] }
          h4 { ["font-size: 30px", "line-height: 35px"] }
          h5 { ["font-size: 25px", "line-height: 30px"] }
          h6 { ["font-size: 20px", "line-height: 25px"] }
        end

        align do
          left   { "text-align: left" }
          center { "text-align: center" }
          right  { "text-align: right" }
        end

        color do
          regular     { "color: #14181F" }
          placeholder { "color: #8B939F" }
          info        { "color: #1C51A4" }
          success     { "color: #60830D" }
          warning     { "color: #82620F" }
          error       { "color: #AB2816" }
        end

        weight do
          regular  { "font-weight: 400" }
          bold     { "font-weight: 700" }
        end
      end

      default_variant level: :h1, align: :center, color: :regular, weight: :regular

      def initialize(text = nil, level: nil, align: nil, color: nil, weight: nil)
        super()
        @text = text
        @level = level
        @align = align
        @color = color
        @weight = weight
      end

      def text
        content.presence || @text
      end

      def template
        style = style(level:, align:, color:, weight:)

        tag.send(level, text, style:)
      end

      private

      attr_reader :level, :align, :color, :weight
    end
  end
end
