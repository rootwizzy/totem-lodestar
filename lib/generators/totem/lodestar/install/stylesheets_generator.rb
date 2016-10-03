module Totem
  module Lodestar
    module Install
      class StylesheetsGenerator < Rails::Generators::Base
        desc "Install Totem Lodestar stylesheets."
        source_root File.expand_path('../templates', __FILE__)

        def inject_engine_css
          template "application.css.scss", File.join(app_css_dir, "application.css.scss"), skip: true
          remove_file File.join(app_css_dir, "application.css")
          append_to_file app_css_file, "@import 'variables/modules';\n"
          append_to_file app_css_file, "@import 'totem-lodestar';\n"
          template "_modules.scss", File.join(app_css_dir, "variables", "_modules.scss"), skip: true
        end

        def app_css_dir; File.join("app", "assets", "stylesheets") end
        def app_css_file; File.join(app_css_dir, "application#{css_format[0]}") end

        def css_format
          %w(.css .css.sass .sass .css.scss .scss).each do |ext|
            if File.exist?(File.join(app_css_dir, "application#{ext}"))
              if ext.include?(".sass") || ext.include?(".scss") then comment = "//=" else comment = " *=" end
              return [ext, comment]
            end
          end
        end

      end
    end
  end
end