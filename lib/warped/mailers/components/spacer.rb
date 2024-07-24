# frozen_string_literal: true

module Warped
  module Mailers
    class Spacer < Base
      variant do
        base { "height: 20px" }
      end

      def template(&)
        tag.div(nil, style:)
      end
    end
  end
end
