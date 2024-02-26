# frozen_string_literal: true

module Boosted
  class Railtie < Rails::Railtie
    rake_tasks do
      load "boosted/tasks/boosted.rake"
    end
  end
end
