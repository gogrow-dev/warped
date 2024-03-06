# frozen_string_literal: true

require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/string/inflections"
require "action_view/helpers"

module Warped
  module Emails
    class Base
      include ActionView::Helpers::CaptureHelper
      include Slottable
      include Styleable

      attr_reader :view_context

      delegate :capture, :tag, :content_tag, to: :view_context
      delegate_missing_to :view_context

      def template
        raise NotImplementedError
      end

      def content
        @content_block
      end

      def helpers
        return view_context if view_context.present?

        raise ArgumentError, "helpers cannot be used during initialization, as it depends on the view context"
      end

      def render_in(view_context, &block)
        @view_context = view_context

        @content_block = capture { block.call(self) } if block_given?
        template
      end
    end
  end
end
