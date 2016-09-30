module Totem
  module Lodestar
    module Generator  
      module Parser
        DOCUMENTS_DIR = '/public/documents'

        attr_accessor :doc_hash

        ## Initializes module attributes when included in the rake task
        def self.included(base)
          Generator::Parser::doc_hash = {}
          change_to(Dir.pwd + DOCUMENTS_DIR, false) {}
        end

        ## Called by the rake task
        def generate_document_structure; build_document_hash end

        private
        def build_document_hash
          ## Generate the base version keys for the doc_hash
          Dir.glob("*.*.*").each {|version| Generator::Parser::doc_hash[version] = {};}
          ## Recursively generates the document structure for each version folder
          Generator::Parser::doc_hash.each {|version, hash| add_files_and_sections(version, hash);} 
        end

        ## Sets the files and sections keys for a given hash
        def add_files_and_sections(dir, hash)
          files, dirs      = scrape_dir(dir)
          hash['files']    = build_files_array(files, dir)   unless files.empty?
          hash['sections'] = build_sections_array(dirs, dir) unless dirs.empty?
          hash
        end

        ## Takes a directory and returns an array of files and an array of directories
        def scrape_dir(dir)
          files, dirs = ''
          change_to(dir) do
            files = Dir.glob("*.*")                    ## ["test.md", "test2.md"]
            dirs  = Dir.glob("*")                      ## ["Deploy", "Help", "test.md"]
            dirs.delete_if {|dir| files.include?(dir)} ## ["Deploy", "Help"]
          end
          return files, dirs
        end

        def build_sections_array(sections, cur)
          build_array do |arr|
            change_to(cur) do
              sections.each {|section| arr.push(create_section_object(section))}
            end
          end
        end

        def build_files_array(files, dir)
          build_array {|arr| files.each {|file| arr.push(create_document_object(file, dir))}}
        end

        def create_document_object(file, dir)
          document = nil
          change_to(dir) {|dir| document = {title: file, path: dir + '/' + file}}
          document
        end

        def create_section_object(dir)
          section = {title: dir}
          section = add_files_and_sections(dir, section)
        end

        def build_array
          arr = []
          yield(arr)
          arr
        end

        def change_to(dir, back=true)
          Dir.chdir(dir)
          yield(Dir.pwd)
          Dir.chdir('..') if back
        end
      end

      module Migrator
        attr_accessor :migrated_versions, :migrated_sections, :migrated_documents
        attr_accessor :previous_versions, :previous_sections, :previous_documents

        def version_class;  Totem::Lodestar::Version  end
        def section_class;  Totem::Lodestar::Section  end
        def document_class; Totem::Lodestar::Document end

        def self.included(base)
          Generator::Migrator::migrated_versions  = []
          Generator::Migrator::migrated_sections  = []
          Generator::Migrator::migrated_documents = []

          Generator::Migrator::previous_versions  = []
          Generator::Migrator::previous_sections  = []
          Generator::Migrator::previous_documents = []
        end

        def add_version(version);   Generator::Migrator::migrated_versions.push(version);   version  end
        def add_section(section);   Generator::Migrator::migrated_sections.push(section);   section  end
        def add_document(document); Generator::Migrator::migrated_documents.push(document); document end

        ## Take document structure from the parser and get or create db records for them, then remove any
        ## documents that were not parsed to remove any deleted version/sections/documents.
        def migrate_document_structure
          set_previous_migrations

          Generator::Parser::doc_hash.each do |version, data|
            text = get_version_index_text(data['files'], version)
            version_record = get_or_create_version(version, text)

            if data['files']    then migrate_documents(data['files'], nil, version_record) end
            if data['sections'] then migrate_sections(data['sections'], version_record)    end
          end

          destroy_removed_migrations
        end

        def set_previous_migrations
          Generator::Migrator::previous_versions  = version_class.all
          Generator::Migrator::previous_sections  = section_class.all
          Generator::Migrator::previous_documents = document_class.all
        end

        def destroy_removed_migrations
          versions_to_remove = Generator::Migrator::previous_versions.to_a.keep_if do |version|
            !Generator::Migrator::migrated_versions.include?(version)
          end

          sections_to_remove = Generator::Migrator::previous_sections.to_a.keep_if do |sections|
            !Generator::Migrator::migrated_sections.include?(sections)
          end

          documents_to_remove = Generator::Migrator::previous_documents.to_a.keep_if do |document|
            !Generator::Migrator::migrated_documents.include?(document)
          end

          [versions_to_remove, sections_to_remove, documents_to_remove].each {|records| records.each {|record| record.destroy}}
        end

        ## Check the version hash for an index.md or return default text
        def get_version_index_text(data, version)
          index = 
            "
            # #{version}
            No Index Found.
            To contribute add an index.md to the base directory of this version!
            "
          if data and data.select {|file| file[:title] == 'index.md'} then index = File.read(data[0][:path]) end
        end

        def migrate_sections(sections, version, parent=nil)
          sections.each do |section|
            section_record = get_or_create_section(section, version, parent)
            migrate_documents(section['files'], section_record, version)
            if section['sections'] then migrate_sections(section['sections'], version, section_record) end
          end
        end

        def migrate_documents(files, section, version)
          files.each do |file|
            document              = {}
            document[:title]      = file[:title].sub(/.md/, '')
            document[:body]       = File.read(file[:path])
            document[:section_id] = if section then section.id else nil end
            document[:version_id] = version.id
            get_or_create_document(document)
          end      
        end

        def get_or_create_document(document)
          order = set_order_from_title(document[:title])
          obj   = document_class.find_or_create_by(title: document[:title], section_id: document[:section_id], version_id: document[:version_id])
          document_class.find(obj) ## Hacky to generate the :slug for FriendlyId
          obj.body  = document[:body]
          if order then obj.order = order else obj.order = nil end
          obj.save
          add_document(obj)
        end

        def get_or_create_version(title, text)
          version      = version_class.find_or_create_by(title: title)
          version.body = text if text
          version.save
          add_version(version)
        end

        def get_or_create_section(section, version, parent)
          order          = set_order_from_title(section[:title])
          section        = section_class.find_or_create_by(title: section[:title], version_id: version.id)
          section.parent = parent if parent
          section.order  = order if order
          section.save
          add_section(section)
        end

        def set_order_from_title(title)
          has_order = /^[0-9]?[0-9]_/.match(title)
          if has_order
            order = has_order.to_s.to_i
            title.gsub!(/^[0-9]?[0-9]_/, '')
            return order
          end
        end

      end
    end
  end
end