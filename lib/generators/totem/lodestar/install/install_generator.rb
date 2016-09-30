module Totem
  module Lodestar
    class InstallGenerator < Rails::Generators::Base
      desc "Install Totem Lodestar application assets."
      source_root File.expand_path('../templates', __FILE__)

      # argument :layout_name, :type => :string, :default => "application", :banner => "layout_name"
      # class_option :test_option, desc: "Uncomment this if options required", type: :boolean

      def install
        invoke "totem:lodestar:install:javascripts"
        invoke "totem:lodestar:install:stylesheets"
      end

    end
  end
end