require 'test_helper'
module Totem
  module Lodestar 
    class VersionsControllerTest < ActionDispatch::IntegrationTest
      include Engine.routes.url_helpers

      setup do
        @version_fixtures = totem_lodestar_versions(:v1, :v2)
        @routes = Engine.routes
      end

      test "versions show" do
        @version_fixtures.each do |version|
          get "/#{version.id}"
          assert_response :success
        end
      end
    end
  end
end
