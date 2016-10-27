module Totem
  module Lodestar
    module Install
      class ViewsGenerator < Rails::Generators::NamedBase
        desc "Install Totem Lodestar views"
        source_root File.expand_path('../templates', __FILE__)

        def inject_engine_views
          template 'application.html.slim.tt', './app/views/layouts/application.html.slim', skip: true
        end

      end
    end
  end
end