module Totem
  module Lodestar
    module Install
      class TravisCiGenerator < Rails::Generators::NamedBase
        desc "Install Totem Lodestar database settings"
        source_root File.expand_path('../templates', __FILE__)

        def inject_engine_config_settings
          template '.travis.tt', './.travis.yml', skip: true
          template 'database.yml.travis.tt', './config/database.yml.travis', skip: true
        end

      end
    end
  end
end