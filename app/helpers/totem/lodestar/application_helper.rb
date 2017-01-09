module Totem
  module Lodestar
    module ApplicationHelper
      def p_render(path); render File.join("totem","lodestar", path) end
    end
  end
end
