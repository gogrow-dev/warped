# frozen_string_literal: true

require "warped"
require "rails"
require "request_helper"

RSpec.configure do |config|
  require "active_job"

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include RequestHelper, type: :controller
end
