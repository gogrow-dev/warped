# frozen_string_literal: true

require "active_support/core_ext/string/inflections"

module Boosted
  module Jobs
    # Base class for all jobs in Boosted.
    class Base < ::Boosted.base_job_parent_class.constantize
    end
  end
end
