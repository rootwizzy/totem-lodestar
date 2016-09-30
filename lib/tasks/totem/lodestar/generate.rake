require_relative 'helpers/generator'

namespace :totem do
  namespace :lodestar do
    desc "Parses markdown documents then migrates to the database"
    task generate: :environment do
      include Totem::Lodestar::Generator::Migrator, Totem::Lodestar::Generator::Parser
      generate_document_structure
      migrate_document_structure
    end

    desc "Regenerates all slugs"
    task reset_slugs: :environment do
      [Version, Section, Document].each {|klass| klass.all.each {|record| record.slug = nil; record.save}}
    end
  end
end
