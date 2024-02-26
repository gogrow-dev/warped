# frozen_string_literal: true

require "warped/jobs/base"

module Warped
  module Services
    # Base class for all services
    #
    # This class provides a simple interface for creating services.
    # It also provides a way to call services asynchronously using +ActiveJob+.
    #
    # @example Create a service
    #   class PrintService < Warped::Services::Base
    #     def call(message)
    #       puts message
    #     end
    #   end
    #
    #   SomeService.call('Hello World') # => "Hello World"
    #   SomeService.new('Hello World').call # => "Hello World"
    #
    # @example Call a service asynchronously
    #  class SlowService < Warped::Services::Base
    #    enable_job!
    #
    #    def call(message)
    #      sleep 5
    #      puts message
    #    end
    #  end
    #
    #  SlowService.call_later('Hello World') # => "Hello World" after 5 seconds
    #  SlowService::Job.perform_later('Hello World') # => "Hello World" after 5 seconds
    class Base
      def self.call(...)
        new(...).call
      end

      def self.call_later(...)
        unless @job_enabled
          message = "#{self.class.name}::Job is not implemented, make sure to call enable_job! in the service"
          raise NotImplementedError, message
        end

        self::Async.perform_later(...)
      end

      def call
        raise NotImplementedError, "#{self.class.name}#call not implemented"
      end

      # This method is used to create a Job class that inherits from +Warped::Jobs::Base+
      # and calls the service asynchronously.
      # @example Enable async for a service
      #   class SomeService < Warped::Services::Base
      #     enable_job!
      #
      #     def call(...)
      #       # service logic
      #     end
      #   end
      #
      #   # SomeService.call_later(...)
      #   # SomeService::Job.perform_later(...)
      def self.enable_job!
        @job_enabled = true

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          # class SomeService
          #   class Job < Warped::Jobs::Base
          #
          #     def perform(...)
          #       SomeService.call(...)
          #     end
          #   end
          #
          #   def self.call_later(...)
          #     Job.perform_later(...)
          #   end
          # end
          class Job < Warped::Jobs::Base
            def perform(...)
              #{name}.call(...)
            end
          end

          def self.call_later(...)
            Job.perform_later(...)
          end
        RUBY
      end
    end
  end
end
