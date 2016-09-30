module Totem
  module Lodestar
    module Install
      class JavascriptsGenerator < Rails::Generators::Base
        desc "Install Totem Lodestar application assets."
        source_root File.expand_path('../templates', __FILE__)

        def inject_engine_js_require
          insert_into_file( File.join(app_js_dir, "application.js"), "//= require #{engine_js_dir}\n", {before: '//= require_tree .'})
        end

        def app_js_dir;    File.join("app", "assets", "javascripts")     end
        def engine_js_dir; File.join("totem", "lodestar", "application") end

      end
    end
  end
end