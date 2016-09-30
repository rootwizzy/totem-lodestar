require 'test_helper'
require 'generators/totem/lodestar/install/install_generator'

module Totem::Lodestar
  class Totem::Lodestar::InstallGeneratorTest < Rails::Generators::TestCase
    tests Totem::Lodestar::InstallGenerator
    destination Rails.root.join('tmp/generators')
    setup :prepare_destination

    # test "generator runs without errors" do
    #   assert_nothing_raised do
    #     run_generator ["arguments"]
    #   end
    # end
  end
end
