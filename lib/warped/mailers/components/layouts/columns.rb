# frozen_string_literal: true

module Warped
  module Mailers
    module Layouts
      class Columns < Base
        variant do
          base { ["display: inline"] }
        end

        variant :col do
          base do
            [
              "width: #{(100 / cols.size.to_f).round(4)}%",
              "display: inline-block",
              "vertical-align: top",
              "text-align: center"
            ]
          end
        end

        slots_many :cols

        def template
          tag.div(style:) do
            capture do
              cols.each do |col|
                concat tag.div(col, style: style(:col))
              end
            end
          end
        end
      end
    end
  end
end
