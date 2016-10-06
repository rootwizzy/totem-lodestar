require 'test_helper'

module Totem
  module Lodestar
    class SectionsControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      setup do
        @section_fixtures = totem_lodestar_sections(:v1_s1, :v1_s2)
        @routes = Engine.routes 
      end

      test "versions show" do
        @section_fixtures.each do |section|
          get "/#{section.version_id}/#{section.id}"
          assert_response :redirect
        end
      end
    end
  end
end
