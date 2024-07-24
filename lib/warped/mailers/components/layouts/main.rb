# frozen_string_literal: true

module Warped
  module Mailers
    module Layouts
      class Main < Base
        variant do
          base do
            [
              "font-family: 'Open Sans', 'Roboto', 'Segoe UI', Arial, sans-serif",
              "max-width: 600px", "margin: 60px auto 60px auto",
              "padding: 15px", "background-color: #fff",
              "border-radius: 5px",
              "box-shadow: 0 0 10px rgba(0, 0, 0, 0.1)"
            ]
          end
        end

        slots_one :header
        slots_one :main
        slots_one :footer

        def template(&)
          tag.div(style:) do
            content_tag(:div, style: "vertical-align: middle;") do
              concat tag.header(header) if header?
              concat tag.main(main) if main?
              concat tag.footer(footer) if footer?
            end
          end
        end
      end
    end
  end
end
