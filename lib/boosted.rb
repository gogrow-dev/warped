# frozen_string_literal: true

require "active_support/configurable"

##
# The main module for the Boosted gem.
#
# This module is used to provide configuration options for the gem.
#
# @example Configurations
#   # config/initializers/boosted.rb
#
#   Boosted.configure do |config|
#     config.base_job_parent_class = "ApplicationJob" # Default: "ActiveJob::Base"
#   end
#
# @see https://api.rubyonrails.org/classes/ActiveSupport/Configurable.html
#
module Boosted
  include ActiveSupport::Configurable

  config_accessor :base_job_parent_class, instance_accessor: false, default: "ActiveJob::Base"
end

# load all files in lib/boosted except for the tasks
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup
loader.ignore("lib/boosted/tasks")
loader.ignore("lib/boosted/railtie.rb") unless defined?(Rails::Railtie)
loader.eager_load
