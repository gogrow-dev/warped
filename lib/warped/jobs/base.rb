# frozen_string_literal: true

require "active_job"
require "active_support/core_ext/string/inflections"

module Warped
  module Jobs
    ##
    # Base class for all jobs in the application.
    # This class is used to provide a common interface for all jobs used by Warped
    # and to allow for easy configuration of the parent class.
    # By default, the parent class is set to +ActiveJob::Base+.
    # @see Warped
    #
    # @example Change the parent class for Warped::Jobs::Base
    #   Warped.configure do |config|
    #     config.base_job_parent_class = "ApplicationJob"
    #   end
    #
    class Base < Warped.base_job_parent_class.constantize
    end
  end
end
