# frozen_string_literal: true

require "active_support/concern"

module Warped
  module Emails
    module Helpers
      extend ActiveSupport::Concern

      included do
        helper_method :frontend_url
      end

      def frontend_url(path = [])
        frontend_path = Array(path)

        url = base_url
        path ? [url, *frontend_path].join("/").gsub(%r{(?<!:)//}, "/") : url
      end

      def base_url
        ENV["FRONTEND_URL"].presence || ENV["SERVER_HOST"].presence || "http://localhost:3000"
      end
    end
  end
end
