module Totem
  module Lodestar
    module Install
      class StylesheetsGenerator < Rails::Generators::Base
        desc "Install Totem Lodestar application assets."
        source_root File.expand_path('../templates', __FILE__)

        # argument :layout_name, :type => :string, :default => "application", :banner => "layout_name"
        # class_option :test_option, desc: "Uncomment this if options required", type: :boolean

        def inject_engine_css_require
          insert_into_file(File.join(app_css_dir, "application.css.scss"), "*= require #{engine_css_dir}\n", {before: '*= require_self'})
        end

        def app_css_dir;    File.join("app", "assets", "stylesheets")     end
        def engine_css_dir; File.join("totem", "lodestar", "application") end

      end
    end
  end
end