require_relative 'helpers/guides_generator'
require_relative 'helpers/api_generator'

namespace :totem do
  namespace :lodestar do
    desc "Parses markdown documents then migrates to the database"
    task generate: :environment do
      include Totem::Lodestar::GuidesGenerator::Migrator, Totem::Lodestar::GuidesGenerator::Parser
      generate_document_structure
      migrate_document_structure
    end

    desc "Regenerates all slugs"
    task reset_slugs: :environment do
      [Version, Section, Document].each {|klass| klass.all.each {|record| record.slug = nil; record.save}}
    end

    desc "Generate API documentation"
    task :api, [:build] => [:environment] do
      |t, args|
      include Totem::Lodestar::ApiGenerator
      build = args.build.eql?("true") ? true : false
      generate_api_documents(build)
    end
  end
end
