# frozen_string_literal: true

module Warped
  module Emails
    class Table < Base
      variant do
        base do
          [
            "border-collapse: collapse"
          ]
        end
      end

      variant :row do
        base { ["border-bottom: 1px solid #f0f0f0"] }
      end

      variant :header do
        base { ["background-color: #f9f9f9"] }
      end

      slots_one :header
      slots_many :rows

      def initialize(content)
        super()
        @content = content
      end

      def template
        raise ArgumentError, "at least one row must be passed to the table" if rows_content.empty?

        tag.table(style) do
          concat tag.thead(header, style: header_style) if header.present?
          if rows.any?
            concat tag.tbody do
              rows.each do |row|
                concat tag.tr(row, style: row_style)
              end
            end
          end
        end
      end
    end
  end
end
