module Totem
  module Lodestar
    class Engine < ::Rails::Engine
      isolate_namespace Totem::Lodestar
      engine_name 'totem_lodestar'


      initializer "totem_lodestar", before: :load_config_initializers do |app|

        config.paths["db/migrate"].expanded.each do |expanded_path|
          Rails.application.config.paths["db/migrate"] << expanded_path
        end
      end

    end
  end
end
