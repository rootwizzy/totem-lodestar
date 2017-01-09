module Totem
  module Lodestar
    module Install
      class JavascriptsGenerator < Rails::Generators::Base
        desc "Install Totem Lodestar javascripts."
        source_root File.expand_path('../templates', __FILE__)

        def inject_engine_js
          insert_into_file(app_js_file, "#{js_format[1]} require totem-lodestar\n", {before: "#{js_format[1]} require_tree ."})
        end

        def install_npm_packages
          template 'package.json.tt', './package.json'
        end

        def app_js_file; File.join("app", "assets", "javascripts", "application#{js_format[0]}") end
        def app_js_dir; File.join("app", "assets", "javascripts") end

        def js_format
          %w(.coffee .coffee.erb .js.coffee .js.coffee.erb .js .js.erb).each do |ext|
            if File.exist?(File.join(app_js_dir, "application#{ext}"))
              if ext.include?(".coffee") then comment = "#=" else comment = "//=" end
              return [ext, comment]
            end
          end
        end

        d

      end
    end
  end
end