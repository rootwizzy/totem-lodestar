module Totem
  module Lodestar
    class GuidesController < ::ApplicationController
      before_action :set_globals

      def set_globals
        @version   = Version.friendly.find(params[:version_id])             if params[:version_id]
        @section   = @version.sections.friendly.find(params[:section_id])   if params[:section_id]
        @document  = @section.documents.friendly.find(params[:document_id]) if params[:document_id]
      end
    end
  end
end