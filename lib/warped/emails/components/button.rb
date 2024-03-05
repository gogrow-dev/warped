# frozen_string_literal: true

module Warped
  module Emails
    class Button < Base
      variant do
        base do
          ["font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif",
           "font-weight: 400",
           "color: #333",
           "text-decoration: none",
           "display: inline-block",
           "padding: 10px 20px",
           "border-radius: 4px",
           "border: 1px solid #ccc",
           "background-color: #f4f4f4",
           "color: #fff"]
        end

        type do
          primary { ["background-color: #3498db", "border-color: #3498db"] }
          success { ["background-color: #2ecc71", "border-color: #2ecc71"] }
          warning { ["background-color: #f39c12", "border-color: #f39c12"] }
          danger  { ["background-color: #e74c3c", "border-color: #e74c3c"] }
        end

        size do
          sm { ["font-size: 12px", "padding: 4px 8px"] }
          md { ["font-size: 14px", "padding: 6px 12px"] }
          lg { ["font-size: 16px", "padding: 8px 16px"] }
        end
      end

      default_variant type: :primary, size: :md

      def initialize(text = nil, href, type: :primary, size: :md)
        super()
        @text = text
        @href = href
        @type = type
        @size = size
      end

      def text
        content.presence || @text
      end

      def template
        style = style(type:, size:)

        tag.a(text, href:, style:)
      end

      private

      attr_reader :href, :type, :size
    end
  end
end
