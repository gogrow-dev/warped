# frozen_string_literal: true

module Warped
  module Emails
    module Layouts
      class Main < Base
        variant do
          base do
            [
              "max-width: 600px", "margin: 20px auto 0 auto", "padding: 20px 30px",
              "background-color: #fff", "border-radius: 5px", "box-shadow: 0 0 10px rgba(0, 0, 0, 0.1)"
            ]
          end
        end

        slots_one :header
        slots_one :main
        slots_one :footer

        def template(&)
          tag.div(style:) do
            content_tag(:div, style: "vertical-align: middle;") do
              concat tag.header(header)
              concat tag.main(main)
              concat render Divider.new
              concat tag.footer(footer)
            end
          end
        end
      end
    end
  end
end
