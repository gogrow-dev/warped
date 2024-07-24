# frozen_string_literal: true

module Warped
  module Mailers
    class Stepper < Base
      variant :step do
        base do
          ["border-radius: 100%;", "width: #{width}%",
           "max-width: #{max_width}px", "height: #{height}px",
           "text-align: center", "line-height: #{height}px",
           "display: inline-block", "font-size: #{height / 2}px",
           "border: 1px solid #007bff"]
        end

        state do
          active { ["background-color: #007bff", "color: #fff"] }
          inactive { ["background-color: #fff", "color: #007bff"] }
        end
      end

      variant :step_divider do
        base do
          ["height: 3px", "border-radius: 3px", "width: 100%"]
        end

        state do
          active { ["background-color: #007bff;"] }
          inactive { ["background-color: #ddd;"] }
        end
      end

      variant :table do
        base do
          ["display: inline-block", "min-width: 30px", "width: #{width}%",
           "height: #{height}px", "border-collapse: collapse", "vertical-align: middle"]
        end
      end

      default_variant size: :md, color: :info, display: :block

      def initialize(steps:, current_step: 1)
        super()
        @steps = steps
        @current_step = current_step
      end

      def template
        tag.div(style: "width: 100%") do
          capture do
            (1..steps).map do |step|
              if step <= current_step
                concat step(step, state: :active)
              else
                concat step(step, state: :inactive)
              end

              if step < steps
                concat divider(state: step <= current_step ? :active : :inactive)
              end
            end
          end
        end
      end

      private

      attr_reader :steps, :current_step

      def step(number, state:)
        tag.div(style: "#{style(:step, state:)}; width: #{width}%;") do
          tag.span(number)
        end
      end

      def divider(state:)
        tag.table(style: style(:table)) do
          tag.tbody(style: "width: 100%; height: 100%; display: table") do
            tag.tr(style: "width: 100%; height: 100%") do
              tag.td(valign: :middle,
                     style: "vertical-align: middle; text-align: center; height: 100%; width: 100%; padding: 0 3px") do
                tag.div(style: style(:step_divider, state:))
              end
            end
          end
        end
      end

      def width
        (100 / (steps + (steps - 1))).round(4) - 0.8
      end

      def max_width
        50
      end

      def height
        50
      end
    end
  end
end
