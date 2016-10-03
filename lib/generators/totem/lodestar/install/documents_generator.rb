module Totem
  module Lodestar
    module Install
      class DocumentsGenerator < Rails::Generators::Base
        desc "Install Totem Lodestar test documents"
        source_root File.expand_path('../templates', __FILE__)

        def inject_engine_config_settings
          directory 'documents', 'public/documents'
        end

      end
    end
  end
end