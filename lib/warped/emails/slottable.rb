# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/module/attribute_accessors"

module Warped
  module Emails
    module Slottable
      extend ActiveSupport::Concern

      included do
        class_attribute :slots, default: { one: {}, many: {} }
      end

      class_methods do
        def slots_one(name)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # def with_header(&block)
            #   slots[:one][:header] = block
            # end
            #
            # def header
            #   capture(&slots[:one][:header]) if slots[:one][:header]
            # end
            def with_#{name}(&block)
              slots[:one][:#{name}] = block
            end

            def #{name}
              capture(&slots[:one][:#{name}]) if slots[:one][:#{name}]
            end
          RUBY
        end

        def slots_many(name)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # def with_header(&block)
            #   slots[:many][:headers] ||= []
            #   slots[:many][:headers] << block
            # end
            #
            # def headers
            #   return [] if slots[:many][:headers].empty?
            #
            #   slots[:many][:headers].map { |block| capture(&block) }
            # end
            def with_#{name.to_s.singularize}(&block)
              slots[:many][:#{name}] ||= []
              slots[:many][:#{name}] << block
            end

            def #{name}
              return [] if slots[:many][:#{name}].empty?

              slots[:many][:#{name}].map { |block| capture(&block) }
            end
          RUBY
        end
      end
    end
  end
end
