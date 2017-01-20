module Totem
  module Lodestar
    module ApplicationHelper
      def p_render(path); render File.join("totem","lodestar", path) end

      def get_settings_text(var)
        Settings[:text][var]
      end
    end
  end
end
