module Totem
  module Lodestar
    module Install
      class JavascriptsGenerator < Rails::Generators::Base
        desc "Install Totem Lodestar application assets."
        source_root File.expand_path('../templates', __FILE__)

        def inject_engine_js_require
          insert_into_file( app_js, "//= require totem-lodestar\n", {before: '//= require_tree .'})
        end

        def app_js; File.join("app", "assets", "javascripts", "application.js")     end

      end
    end
  end
end