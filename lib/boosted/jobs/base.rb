# frozen_string_literal: true

require "active_job"
require "active_support/core_ext/string/inflections"

module Boosted
  module Jobs
    ##
    # Base class for all jobs in the application.
    # This class is used to provide a common interface for all jobs used by Boosted
    # and to allow for easy configuration of the parent class.
    # By default, the parent class is set to +ActiveJob::Base+.
    # @see Boosted
    #
    # @example Change the parent class for Boosted::Jobs::Base
    #   Boosted.configure do |config|
    #     config.base_job_parent_class = "ApplicationJob"
    #   end
    #
    class Base < Boosted.base_job_parent_class.constantize
    end
  end
end
