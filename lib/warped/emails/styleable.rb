# frozen_string_literal: true

require "active_support/concern"
require "active_support/core_ext/module/attribute_accessors"
require "active_support/core_ext/module/delegation"

module Warped
  module Emails
    module Styleable
      extend ActiveSupport::Concern

      class_methods do
        def default_variants
          @default_variants ||= {}
        end

        def base_styles
          @base_styles ||= {}
        end

        def variants
          @variants ||= {}
        end

        def variant(name = :_base_variant, &)
          raise ArgumentError, "You must provide a block" unless block_given?

          variant_builder = VariantBuilder.new(self, variant_name: name)
          variant_builder.compile_variants(&)
        end

        def default_variant(variant_name = :_base_variant, **kwargs)
          raise ArgumentError, "You must provide a hash" unless kwargs.is_a?(Hash)

          self.default_variants ||= {}
          self.default_variants[variant_name] = kwargs
        end
      end

      def default_variants
        self.class.default_variants
      end

      def base_styles
        self.class.base_styles
      end

      def variants
        self.class.variants
      end

      def style(variant_name = :_base_variant, **kwargs)
        base_style_arr = base_block_value(variant_name)

        validate_variants!(variant_name, **kwargs)

        default_variants[variant_name] ||= {}
        default_variants[variant_name].merge(kwargs).each do |group_name, subvariant_name|
          subvariant_arr = variant_block_value(variant_name, group_name, subvariant_name)
          base_style_arr.concat(subvariant_arr)
        end

        base_style_arr.join("; ")
      end

      # @!visibility private
      class VariantBuilder < BasicObject
        delegate :variants, to: :@component

        def initialize(component, variant_name: :_base_variant, group_name: nil)
          @component = component
          @group_name = group_name
          @variant_name = variant_name
        end

        def compile_variants(&)
          instance_eval(&)
        end

        def method_missing(name, &)
          return super unless ::Kernel.block_given?

          if !@group_name && name == :base
            _defin_base_style(&)
          elsif !@group_name
            _define_variant_group(name, &)
          else
            _define_subvariant(name, &)
          end
        end

        def respond_to_missing?(...) = true

        private

        def _define_variant_group(name, &)
          VariantBuilder.new(@component, variant_name: @variant_name, group_name: name).compile_variants(&)
        end

        def _define_subvariant(name, &block)
          variants[@variant_name] ||= {}
          variants[@variant_name][@group_name] ||= {}
          variants[@variant_name][@group_name][name] = block
        end

        def _defin_base_style(&block)
          @component.base_styles[@variant_name] = block
        end
      end

      private_constant :VariantBuilder

      private

      def base_block_value(variant_name)
        return [] unless base_styles.key?(variant_name.to_sym)

        base_block = base_styles[variant_name.to_sym]
        Array.wrap(instance_eval(&base_block))
      end

      def variant_block_value(variant_name, group_name, subvariant_name)
        variant_block = self.class.variants[variant_name][group_name.to_sym][subvariant_name.to_sym]
        Array.wrap(instance_eval(&variant_block))
      end

      def validate_variants!(name, **kwargs)
        kwargs.each do |group_name, variant_name|
          unless variants[name].key?(group_name.to_sym)
            raise ArgumentError,
                  "Invalid variant group: #{group_name}"
          end

          unless variants[name][group_name.to_sym].key?(variant_name.to_sym)
            raise ArgumentError,
                  "Invalid variant name: #{variant_name}"
          end
        end
      end
    end
  end
end
