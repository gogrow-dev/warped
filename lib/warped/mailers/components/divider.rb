# frozen_string_literal: true

module Warped
  module Mailers
    class Divider < Base
      variant do
        base { "border: none; border-top: 1px solid #ddd; margin: 20px 0;" }
      end

      def template
        tag.hr(style:)
      end
    end
  end
end
