require_relative 'helpers/guides_generator'
require_relative 'helpers/api_generator'

#
# # Totem Lodestar Tasks
# These are used to build the markdown and source documentation during the build process. These may be called either locally during development or used within the **.travis.yml** build script.
namespace :totem do
  namespace :lodestar do

    # `rails totem:lodestar:generate`
    # Generate uses the **GuidesGenerator** helpers to build the markdown documents for the guides section of lodestar. This two step process first scrapes the designated documents folder and builds a hash tree that mimics the files and structure. The second part migrates the files into the database removing any deleted documents.
    desc "Parses markdown documents then migrates to the database"
    task generate: :environment do
      include Totem::Lodestar::GuidesGenerator::Migrator, Totem::Lodestar::GuidesGenerator::Parser
      generate_document_structure
      migrate_document_structure
    end

    # `rails totem:lodestar:reset_slugs`
    # Reset slugs is used if there becomes and conflicting slugs for the URL. This will happen if a file/folder happen to use the same string, thus requiring **friendly_id** to generate a very _unfriendly_ id. After fixing the conflict run this command to wipe the existing slug associations which will re-build after accessing those files again.
    desc "Regenerates all slugs"
    task reset_slugs: :environment do
      [Version, Section, Document].each {|klass| klass.all.each {|record| record.slug = nil; record.save}}
    end

    # `rails totem:lodestar:api[build,local]` 
    # 
    # API builds the source code documentation through a forked version of **Groc** and **ApiGenerator**. The generated html is then put into the API folder in the base directory and is served as static assets with corresponding links for rails to navigate to. Without options this just migrates the repos titles for use in linking, building must first be done locally then pushed for production using the two options below. 
    #
    # - `build`: Runs the source parser (groc) to generate the API documents
    # - `local`: Used for local testing, pulls local directory instead of remote github repo
    desc "Generate API documentation"
    task :api, [:build, :local] => [:environment] do
      |t, args|
      include Totem::Lodestar::ApiGenerator
      build = args.build.eql?("build") ? true : false
      local = args.local.eql?("local") ? true : false
      generate_api_documents(build, local)
    end
  end
end
