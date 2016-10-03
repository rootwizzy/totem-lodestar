module Totem
  module Lodestar
    module Install
      class RoutesGenerator < Rails::Generators::Base
        desc "Install Totem Lodestar routes."
        source_root File.expand_path('../templates', __FILE__)

        def inject_engine_routes
          insert_into_file('config/routes.rb', "\n  mount Totem::Lodestar::Engine, at: '/'\n", {after: "Rails.application.routes.draw do"})
        end

      end
    end
  end
end