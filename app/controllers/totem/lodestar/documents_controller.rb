module Totem
  module Lodestar
    class DocumentsController < ApplicationController
      def show; @body = @document.body end
    end
  end
end


