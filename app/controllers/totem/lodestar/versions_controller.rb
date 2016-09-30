module Totem
  module Lodestar    
    class VersionsController < ApplicationController
      def show; @body = @version.body; c_render "layouts/article" end

      def index
        redirect_to action: "show", version_id: Version.last.slug if Settings.modules.version_redirect
        @versions = Version.all
      end
    end
  end
end