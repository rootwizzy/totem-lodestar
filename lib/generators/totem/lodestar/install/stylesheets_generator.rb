module Totem
  module Lodestar
    module Install
      class StylesheetsGenerator < Rails::Generators::Base
        desc "Install Totem Lodestar application assets."
        source_root File.expand_path('../templates', __FILE__)

        # argument :layout_name, :type => :string, :default => "application", :banner => "layout_name"
        class_option :force_templates, desc: "Force overwrite on all stylesheet templates", type: :boolean, default: false
        class_option :skip_templates, desc: "Force skip on all stylesheet templates", type: :boolean, default: false

        def inject_engine_css
          append_to_file app_css_file, "@import 'variables/modules';\n"
          append_to_file app_css_file, "@import 'totem-lodestar';\n"
          template "_modules.scss", File.join(app_css_dir, "variables", "_modules.scss"), skip: true
        end

        def app_css_dir; File.join("app", "assets", "stylesheets") end
        def app_css_file; File.join(app_css_dir, "application.css.scss") end

      end
    end
  end
end