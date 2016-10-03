module Totem
  module Lodestar
    module Install
      class DatabasesGenerator < Rails::Generators::Base
        desc "Install Totem Lodestar database settings"
        source_root File.expand_path('../templates', __FILE__)

        def inject_engine_config_settings
          template 'database.yml', 'config/database.yml'
        end

      end
    end
  end
end