# frozen_string_literal: true

module Warped
  module Emails
    module Layouts
      class Cta < Base
        variant :card do
          base do
            [
              "border-collapse: unset", "width: 100%", "border-spacing: 0",
              "border-radius: 8px", "border: 2px solid #ddd", "padding: 20px"
            ]
          end
        end

        slots_one :title
        slots_one :body
        slots_one :button

        def template
          tag.table(style: style(:card)) do
            tag.tbody do
              tag.tr do
                tag.td(style:) do
                  concat title
                  concat render(Spacer.new)
                  concat body
                  concat render(Spacer.new)
                  concat button
                end
              end
            end
          end
        end
      end
    end
  end
end
