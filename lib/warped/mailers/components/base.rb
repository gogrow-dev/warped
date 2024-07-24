# frozen_string_literal: true

require "active_support/core_ext/module/delegation"
require "action_view/helpers"

module Warped
  module Mailers
    ##
    # Base class for all email components
    #
    # This class provides a number of helper methods for building email components.
    #
    # == Usage
    #
    # To create a new component, you can subclass this class and implement the +template+ method.
    #
    #   class MyComponent < Warped::Emails::Base
    #     def template
    #       content_tag(:div, "Hello, World!")
    #     end
    #   end
    #
    # You can then render the component using the +render+ method in your mailer views
    #
    #   <%= render MyComponent.new %>
    #
    # == Variants
    #
    # Components can define variants using the +variant+ method. Variants are different styles for the component that
    # can be used to change the appearance of the component.
    #
    #   class MyComponent < Warped::Emails::Base
    #     variant do
    #       base { "color: red;" }
    #       size do
    #         sm { "font-size: 12px;" }
    #         md { "font-size: 16px;" }
    #         lg { "font-size: 20px;" }
    #       end
    #     end
    #
    #     default_variant size: :md
    #
    #     def initialize(size: nil)
    #       super()
    #       @size = size
    #     end
    #
    #     def template
    #       content_tag(:div, style: style())
    #     end
    #   end
    #
    # You can then specify the variant to use using the +style+ method in your component
    #
    #   <%= render MyComponent.new %>            # => <div style="color: red; font-size: 16px;"></div>
    #   <%= render MyComponent.new(size: :lg) %> # => <div style="color: red; font-size: 20px;"></div>
    #
    # The variant blocks can return either a string or an array of strings. If an array is returned,
    # the strings will be joined with a semi-colon.
    #
    # The +default_variant+ method can be used to specify the default variant to use if none is specified.
    #
    # The +style+ method can be used to apply the variant styles to the component, or to apply additional styles on
    # top of the variant styles.
    #
    # == Slots
    #
    # Components can define slots using the +slot+ method. Slots are placeholders for content that can be passed
    # in from the outside.
    #
    #   class MyComponent < Warped::Emails::Base
    #     slot :title
    #
    #     def template
    #       content_tag(:div, title)
    #     end
    #   end
    #
    # You can then pass content to the slot using the +with_<slot_name>+ method in your mailer views
    #   <%= render MyComponent.new do |my_component| %>
    #     <% my_component.with_title("Hello, World!") %>
    #   <% end %>
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

      # alias h helpers
    end
  end
end
