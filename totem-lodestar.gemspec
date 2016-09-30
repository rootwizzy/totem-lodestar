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

  # s.add_dependency "pg", "~> 0.18"
  # s.add_dependency "puma", "~> 3.0"
  # s.add_dependency "sass-rails", "~> 5.0"
  # s.add_dependency "uglifier", ">= 1.3.0"
  # s.add_dependency "coffee-rails", "~> 4.2"
  # s.add_dependency "therubyracer"
  # s.add_dependency "jquery-rails"
  # s.add_dependency "jbuilder", "~> 2.5"
  
  s.add_dependency "redcarpet"
  s.add_dependency "nokogiri"
  s.add_dependency "coderay"
  s.add_dependency "friendly_id"
  s.add_dependency "slim"
  s.add_dependency "foundation-rails"
  s.add_dependency "config"



  s.add_development_dependency "sqlite3"
  # s.add_development_dependency "byebug"
  # s.add_development_dependency "rake"
  # s.add_development_dependency "web-console"
  # s.add_development_dependency "listen", "~> 3.0.5"
  # s.add_development_dependency "spring"
  # s.add_development_dependency "spring-wathcher-listen", "~> 2.0.0"

  # s.add_dependency 'tzinfo-data'
end

