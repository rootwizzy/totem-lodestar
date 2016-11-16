require_relative 'helpers/generator'

namespace :totem do
  namespace :lodestar do

    desc "Alias for geneate_guides"
    task generate: :environment do
      Rake::Task['totem:lodestar:generate_guides'].execute
    end

    desc "Parses markdown documents then migrates to the database"
    task generate_guides: :environment do
      include Totem::Lodestar::Generator::Migrator, Totem::Lodestar::Generator::Parser
      generate_document_structure
      migrate_document_structure
    end

    desc "Generate API documentation via YARD"
    task generate_api: :environment do
      
      YARD::Rake::YardocTask.new do |t|
        t.files           = ['app/**/*.rb']   # optional
        # t.options       = ['--any', '--extra', '--opts'] # optional
        # t.stats_options = ['--list-undoc']         # optional
        p "t #{t.inspect}"
      end
      # p "#{Rake::Task[:yard].execute}"
    end

    desc "Regenerates all slugs"
    task reset_slugs: :environment do
      [Version, Section, Document].each {|klass| klass.all.each {|record| record.slug = nil; record.save}}
    end
  end
end
