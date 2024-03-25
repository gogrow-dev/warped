# frozen_string_literal: true

require "rails/generators"

module Warped
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def install
        template "initializer.rb.tt", "config/initializers/warped.rb"
      end
    end
  end
end
