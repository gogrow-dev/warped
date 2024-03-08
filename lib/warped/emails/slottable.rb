# frozen_string_literal: true

module Warped
  module Emails
    module Slottable
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
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
            # def with_column(&block)
            #   slots[:many][:columns] ||= []
            #   slots[:many][:columns] << block
            # end
            #
            # def columns
            #   return [] if slots[:many][:columns].empty?
            #
            #   slots[:many][:columns].map { |block| capture(&block) }
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

      def slots
        @slots ||= { one: {}, many: {} }
      end
    end
  end
end
