# frozen_string_literal: true

module Warped
  class Railtie < Rails::Railtie
    railtie_name :warped

    # add rails generators from Warped
    generators do
      require "generators/warped/install_generator"
    end
  end
end
