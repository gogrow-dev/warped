# frozen_string_literal: true

module Boosted
  module Controllers
    # Boosted::Controlllers::Filterable concern to add filter support to any endpoint
    #  class PostsController < ApplicationController
    #    include Boosted::Controlllers::Filterable
    #    filterable_by :title, :content
    #  end
    #
    # Then in your request you can add the following params:
    #  GET /posts?title_eq=Hello&content_cont=World
    #
    # Filtering by associations is also possible:
    #  class Post < ApplicationRecord
    #    belongs_to :user
    #  end
    #
    #  class User < ApplicationRecord
    #    has_many :posts
    #  end
    #
    #  class PostsController < ApplicationController
    #    include Boosted::Controlllers::Filterable
    #    filterable_by :title, :content, 'users.name'
    #  end
    #
    #  GET /posts?users.name_eq=John&title_cont=My%20First%20Post
    module Filterable
      OPERATORS = {
        "eq" => "=",
        "neq" => "!=",
        "lt" => "<",
        "lteq" => "<=",
        "gt" => ">",
        "gteq" => ">=",
        "like" => "LIKE",
        "in" => "IN",
        "notin" => "NOT IN",
        "null" => "IS NULL",
        "notnull" => "IS NOT NULL",
        "notlike" => "NOT LIKE"
      }.freeze

      module ClassMethods
        def filterable_by(*args)
          string_args = args.map(&:to_s)

          define_method :filterable_by do
            @filterable_by ||= string_args.presence || []
          end

          string_args
        end

        def available_filters(*args)
          string_args = args.map(&:to_s) if args.present?
          string_args ||= OPERATORS.keys

          define_method :available_filters do
            @available_filters ||= string_args
          end

          string_args
        end
      end

      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          attr_writer :filterable_by, :available_filters
        end
      end

      def filter(scope)
        return scope if filterable_by.empty?

        filtering_params.each do |key, value|
          key_str = key.to_s
          has_operator = contains_operator?(key_str)

          param = extract_param(key_str, has_operator)
          operator = extract_operator(key_str, has_operator)

          return scope unless OPERATORS.key?(operator)

          scope = scope.where("#{param} #{OPERATORS[operator]} (?)", value)
        end

        scope
      end

      private

      def filtering_params
        @filtering_params ||= request.parameters.select { |k, _| filterable_by.any? { |f| k.to_s.match?(/^#{f}_/) } }
      end

      def operators_group
        @operators_group ||= OPERATORS.keys.join("|")
      end

      def contains_operator?(key_str)
        !key_str.index(/_(#{operators_group})/).nil?
      end

      def extract_param(key_str, has_operator)
        has_operator ? key_str[/(^.*)_(#{operators_group})/][::Regexp.last_match(1)] : key_str
      end

      def extract_operator(key_str, has_operator)
        has_operator ? key_str[/_(#{operators_group})$/][::Regexp.last_match(1)] : nil
      end
    end
  end
end
