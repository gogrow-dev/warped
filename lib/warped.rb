# frozen_string_literal: true

require "active_support/configurable"

##
# The main module for the Warped gem.
#
# This module is used to provide configuration options for the gem.
#
# @example Configurations
#   # config/initializers/warped.rb
#
#   Warped.configure do |config|
#     config.base_job_parent_class = "ApplicationJob" # Default: "ActiveJob::Base"
#   end
#
# @see https://api.rubyonrails.org/classes/ActiveSupport/Configurable.html
#
module Warped
  include ActiveSupport::Configurable

  config_accessor :base_job_parent_class, instance_accessor: false, default: "ActiveJob::Base"
end

# load all files in lib/warped except for the tasks
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.ignore("#{__dir__}/generators")
loader.ignore("lib/warped/railtie.rb") unless defined?(Rails::Railtie)
loader.collapse("#{__dir__}/warped/emails/components")
loader.collapse("#{__dir__}/warped/api")
loader.setup
loader.eager_load
