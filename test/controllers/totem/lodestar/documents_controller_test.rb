require 'test_helper'

module Totem
  module Lodestar
    class DocumentsControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers
      setup do
        @all_document_fixtures = totem_lodestar_documents(:v1_s1_d1, :v1_s1_d2)
        @routes = Engine.routes
      end

      test "documents show" do
        @all_document_fixtures.each do |document|
          get "/#{document.version_id}/#{document.section_id}/#{document.id}"
          # get document_url(document.version_id, document.section_id, document)
          assert_response :success
        end
      end
    end
  end
end
