# frozen_string_literal: true

module Warped
  module Mailers
    class List < Base
      variant do
        base { "list-style-type: #{numbered ? "decimal" : "none"};" }
      end

      slots_many :items

      def initialize(numbered: false)
        super()
        @numbered = numbered
      end

      def template
        html_tag = numbered ? :ol : :ul

        content_tag(html_tag, style:) do
          safe_join(items.map { |item| content_tag(:li, item.html_safe) })
        end
      end

      private

      attr_reader :numbered
    end
  end
end
