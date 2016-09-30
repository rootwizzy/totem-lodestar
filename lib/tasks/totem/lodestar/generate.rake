require_relative 'helpers/generator'

namespace :totem_lodestar do
  desc "Parses markdown documents and migrates to the database"
  task generate: :environment do
    include Totem::Lodestar::Generator::Migrator, Totem::Lodestar::Generator::Parser
    generate_document_structure
    migrate_document_structure
  end

  desc "Sets all slugs to nil to regenerate"
  task reset_slugs: :environment do
    [Version, Section, Document].each {|klass| klass.all.each {|record| record.slug = nil; record.save}}
  end
end
