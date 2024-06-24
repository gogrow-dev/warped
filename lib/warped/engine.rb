# frozen_string_literal: true

require "rails"

module Warped
  class Engine < ::Rails::Engine
    isolate_namespace Warped

    initializer "warped.assets" do
      if Rails.application.config.respond_to?(:assets)
        Rails.application.config.assets.precompile += %w[warped_manifest.js]
      end
    end

    initializer "warped.importmap", before: "importmap" do |app|
      app.config.importmap.paths << Engine.root.join("config/importmap.rb") if Rails.application.respond_to?(:importmap)
    end
  end
end
