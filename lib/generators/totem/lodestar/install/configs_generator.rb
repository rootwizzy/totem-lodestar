module Totem
  module Lodestar
    module Install
      class ConfigsGenerator < Rails::Generators::Base
        desc "Install Totem Lodestar config gem settings."
        source_root File.expand_path('../templates', __FILE__)

        def inject_engine_config_settings
          generate "config:install -f"
          template 'settings.yml', 'config/settings.yml', force: true
          remove_file 'config/settings.local.yml'
          remove_dir 'config/settings/'
        end

      end
    end
  end
end