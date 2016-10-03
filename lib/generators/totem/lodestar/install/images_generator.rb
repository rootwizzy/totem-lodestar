module Totem
  module Lodestar
    module Install
      class ImagesGenerator < Rails::Generators::Base
        desc "Install Totem Lodestar images."
        source_root File.expand_path('../templates', __FILE__)

        def inject_engine_images
          template "logo.png", File.join(app_images_dir, "logo.png"), skip: true
        end

        def app_images_dir; File.join("app","assets","images") end

      end
    end
  end
end