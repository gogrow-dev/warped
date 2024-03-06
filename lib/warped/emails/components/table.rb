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

      def template
        raise ArgumentError, "at least one row must be passed to the table" if rows.empty?

        content_tag(:table, style:) do
          concat content_tag(:thead, header, style: style(:header))
          concat content_tag(:tbody) do
            rows.each do |row|
              concat content_tag(:tr, row, style: style(:row))
            end
          end
        end
      end
    end
  end
end
