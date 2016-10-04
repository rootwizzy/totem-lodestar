module Totem
  module Lodestar
    module Install
      class TravisCiGenerator < Rails::Generators::Base
        desc "Install Totem Lodestar database settings"
        source_root File.expand_path('../templates', __FILE__)

        def inject_engine_config_settings
          template '.travis.yml', './.travis.yml', skip: true
        end

      end
    end
  end
end