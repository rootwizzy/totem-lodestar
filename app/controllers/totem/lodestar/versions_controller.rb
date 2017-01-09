module Totem
  module Lodestar    
    class VersionsController < GuidesController
      def show; @article = @version end

      def index
        redirect_to action: "show", version_id: Version.last.slug if Settings.modules.versions.index_redirect
        @versions = Version.all
      end
    end
  end
end