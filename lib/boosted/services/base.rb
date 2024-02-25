# frozen_string_literal: true

require "boosted/jobs/base"

module Boosted
  module Services
    # Base class for all services
    #
    # This class provides a simple interface for creating services.
    # It also provides a way to call services asynchronously
    class Base
      def self.call(...)
        new(...).call
      end

      def self.call_later(...)
        self::Async.perform_later(...)
      end

      def call
        raise NotImplementedError, "#{self.class.name}#call not implemented"
      end

      def self.inherited(subclass)
        super

        # This adds an Async class to the service, that inherits from ApplicationJob
        # This allows us to call the service asynchronously like so:
        # SomeService.call_later(...)
        subclass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          # class Async < Boosted::Jobs::Base
          #   queue_as :default
          #
          #   def perform(...)
          #     SomeService.call(...)
          #   end
          # end
          class Async < Boosted::Jobs::Base
            queue_as :default

            def perform(...)
              #{subclass}.call(...)
            end
          end
        RUBY
      end
    end
  end
end
