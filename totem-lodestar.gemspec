$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "totem/lodestar/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "totem-lodestar"
  s.version     = Totem::Lodestar::VERSION
  s.authors     = ["Zachary Johnson"]
  s.email       = ["rootwizzy@gmail.com"]
  s.homepage    = "http://www.sixthedge.com/"
  s.summary     = "Summary of Totem::Lodestar."
  s.description = "Description of Totem::Lodestar."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.0"

  s.add_dependency "pg", "~> 0.18"
  s.add_dependency "redcarpet"
  s.add_dependency "config"
  s.add_dependency "coderay"
  s.add_dependency "friendly_id"
  s.add_dependency "slim"
  s.add_dependency "foundation-rails"
  s.add_dependency "nokogiri"
  # s.add_development_dependency "rake"
end

