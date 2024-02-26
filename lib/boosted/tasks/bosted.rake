# frozen_string_literal: true

namespace :boosted do
  task :install do
    initializer_file = File.join(File.dirname(__FILE__), "templates", "boosted.rb.tt")
    destination = "config/initializers/boosted.rb"

    FileUtils.cp(initializer_file, destination)
  end
end
