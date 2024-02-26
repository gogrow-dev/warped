# frozen_string_literal: true

Boosted.configure do |config|
  # Change the parent class of Boosted::Job::Base.
  # This is useful if you want to use a different ActiveJob parent class.
  # Default: 'ActiveJob::Base'
  # config.base_job_parent_class = 'ActiveJob::Base'
end
