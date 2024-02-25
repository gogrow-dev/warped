# frozen_string_literal: true

require "active_support/configurable"
require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

module Boosted
  include ActiveSupport::Configurable

  config_accessor :base_job_parent_class, instance_accessor: false, default: "ActiveJob::Base"
end
