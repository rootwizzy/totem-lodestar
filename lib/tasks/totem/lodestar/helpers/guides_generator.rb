module Totem; module Lodestar; module GuidesGenerator;
  #
  # # guides_generator.rb
  # - Type: **Rake Helper**
  #
  # The guides generator is used for the markdown guides part of lodestar which takes a set of nested markdown files/folders organizes them then creates database records for routing. The generator is split into two separate modules, the `Parser` and `Migrator`. Both these modules must be included in the rake task to initialize it properly.
  #
  # ----


  # ### Parser Module
  # The `Parser` is the first step of scraping the given documents directory and building a matching hash structure with folder and file objects.
  module Parser
    DOCUMENTS_DIR = '/public/documents'

    attr_accessor :doc_hash

    # Initializes module variables when included in the rake task. Create the wrapper `doc_hash` that will contain the complete folder structure of the public documents directory. We also start by changing to the base documents directory.
    def self.included(base)
      GuidesGenerator::Parser::doc_hash = {}
      change_to(Dir.pwd + DOCUMENTS_DIR, false) {}
    end

    # Entry point from the rake task to begin the building process for the hash
    # @method generate_document_structure
    # @public
    def generate_document_structure; build_document_hash end

    # ### Helpers
    private

    # This is the method that recursively builds the document hash starting at the base directory and adding the files/sections to the hash.
    # @method build_document_hash
    # @private
    def build_document_hash
      # Generate the base version keys for the doc_hash by gobbing all files and folders in the base directory. This means that any folder in the base directory will be treated as a version when being migrated. **You must have at least one version folder**.
      Dir.glob("*.*.*").each {|version| GuidesGenerator::Parser::doc_hash[version] = {};}

      # With the version added to the base level of the `doc_hash` now we recursively generate the document structure for each version.
      GuidesGenerator::Parser::doc_hash.each {|version, hash| add_files_and_sections(version, hash);} 
    end

    # Sets the files and sections keys for a given hash then builds the given file/section for that key.
    # @method add_files_and_sections
    # @private
    # @param {String} dir The name of the directory to scrape files and folders from
    # @param {Hash} hash The hash object used to add the files/sections to.
    def add_files_and_sections(dir, hash)
      files, dirs      = scrape_dir(dir)
      hash['files']    = build_files_array(files, dir)   unless files.empty?
      hash['sections'] = build_sections_array(dirs, dir) unless dirs.empty?
      hash
    end

    # Takes a directory and returns an array of files and an array of directories.
    # @method scrape_dir
    # @private
    # @param {String} dir The directory name to scrape
    def scrape_dir(dir)
      files, dirs = ''
      # Create two arrays from the given directory, one for files and one for directories. These will be used to then add to the `doc_hash` at their respective keys.
      #
      # The files are straight forward, just reg-ex on the `.` to distinguish a file. For directories we must first grab everything then remove anything that matches in the previous file array.
      change_to(dir) do
        files = Dir.glob("*.*")
        dirs  = Dir.glob("*") 
        dirs.delete_if {|dir| files.include?(dir)}
      end
      return files, dirs
    end

    # Takes current directory and creates the sections array for the hash
    # @method build_sections_array
    # @private
    # @param {Array} sections The array of sections to generate objects from
    # @param {String} cur The current directory from the calling method
    def build_sections_array(sections, cur)
      build_array do |arr|
        change_to(cur) do
          sections.each {|section| arr.push(create_section_object(section))}
        end
      end
    end

    # Takes current directory and creates the files array for the hash
    # @method build_files_array
    # @private
    # @param {Array} files The array of files to generate objects from
    # @param {String} dir The directory of the file to add to the object
    def build_files_array(files, dir)
      build_array {|arr| files.each {|file| arr.push(create_document_object(file, dir))}}
    end

    # Creates documents objects to store in the document arrays
    # @method create_document_object
    # @private
    # @param {String} file The name of the file to create the object with
    # @param {String} dir The relative path to the file
    def create_document_object(file, dir)
      document = nil
      change_to(dir) {|dir| document = {title: file, path: dir + '/' + file}}
      document
    end

    # Creates sections objects to store in the sections array
    # @method create_section_object
    # @private
    # @param {String} dir The folder name which will become the section title
    def create_section_object(dir)
      section = {title: dir}
      section = add_files_and_sections(dir, section)
    end

    # Helper method to create an array run a function on it and return it after.
    # @method build_array
    # @private
    def build_array
      arr = []
      yield(arr)
      arr 
    end

    # Helper method to change to a directory, yield to a function for that directory then change back to the previous directory.
    # @method change_to
    # @private
    # @param {String} dir Directory to change to for the yield
    # @param {Boolean} back Change back to the previous directory after the yield.
    def change_to(dir, back=true)
      Dir.chdir(dir)
      yield(Dir.pwd)
      Dir.chdir('..') if back
    end

  end

  # ---

  # ### Migrator Module
  # The `Migrator` takes the directory hash and removes any deleted files and adds all the new files to the database.
  module Migrator
    attr_accessor :migrated_versions, :migrated_sections, :migrated_documents
    attr_accessor :previous_versions, :previous_sections, :previous_documents

    def version_class;  Totem::Lodestar::Version  end
    def section_class;  Totem::Lodestar::Section  end
    def document_class; Totem::Lodestar::Document end

    # Initializes module variables when included in the rake task. These arrays are used for storing the current and upcoming sections/documents and will be used in a differential to create the new set of records.
    def self.included(base)
      GuidesGenerator::Migrator::migrated_versions  = []
      GuidesGenerator::Migrator::migrated_sections  = []
      GuidesGenerator::Migrator::migrated_documents = []

      GuidesGenerator::Migrator::previous_versions  = []
      GuidesGenerator::Migrator::previous_sections  = []
      GuidesGenerator::Migrator::previous_documents = []
    end

    # Helper methods used to add and return the array of migrated records.
    def add_version(version);   GuidesGenerator::Migrator::migrated_versions.push(version);   version  end
    def add_section(section);   GuidesGenerator::Migrator::migrated_sections.push(section);   section  end
    def add_document(document); GuidesGenerator::Migrator::migrated_documents.push(document); document end

    # Take document structure from the parser and get or create db records for them, then remove any documents that were not parsed to remove any deleted version/sections/documents.
    # @method migrate_document_structure
    # @public
    def migrate_document_structure
      set_previous_migrations

      GuidesGenerator::Parser::doc_hash.each do |version, data|
        text = get_version_index_text(data['files'], version)
        version_record = get_or_create_version(version, text)

        if data['files']    then migrate_documents(data['files'], nil, version_record) end
        if data['sections'] then migrate_sections(data['sections'], version_record)    end
      end

      destroy_removed_migrations
    end

    # ### Helpers
    private

    # Grabs all pre-existing records in the database and set the according `previous_...` array to the that.
    # @method set_previous_migrations
    # @private
    def set_previous_migrations
      GuidesGenerator::Migrator::previous_versions  = version_class.all
      GuidesGenerator::Migrator::previous_sections  = section_class.all
      GuidesGenerator::Migrator::previous_documents = document_class.all
    end

    # Remove any records from the database if they do not exists in the differential between the previous migrations and to be migrated records.
    # @method destroy_removed_migrations
    # @private
    def destroy_removed_migrations
      # @todo Make these methods into a more DRY manner for grabbing each record type and diff'ing them.
      # 
      # We create an array for each record type that includes all records that we are going to destroy. We do this by taking the previous records array, converting them to a standard array and keeping them if any previous records occur in the migrated records array.
      versions_to_remove = GuidesGenerator::Migrator::previous_versions.to_a.keep_if do |version|
        !GuidesGenerator::Migrator::migrated_versions.include?(version)
      end

      sections_to_remove = GuidesGenerator::Migrator::previous_sections.to_a.keep_if do |sections|
        !GuidesGenerator::Migrator::migrated_sections.include?(sections)
      end

      documents_to_remove = GuidesGenerator::Migrator::previous_documents.to_a.keep_if do |document|
        !GuidesGenerator::Migrator::migrated_documents.include?(document)
      end

      # After we have all the arrays of records to remove iterate over each array and destroy the records.
      [versions_to_remove, sections_to_remove, documents_to_remove].each {|records| records.each {|record| record.destroy}}
    end

    # Check the version hash for an index.md or return default text if there is none. This allows each version to have an base index page to hit for rails.
    # @method get_version_index_text
    # @private
    # @param {Hash} data The version object to use if applicable
    # @param {String} Version The version title to add to default text if there is no data.
    def get_version_index_text(data, version)
      index = 
        "
        # #{version}
        No Index Found.
        To contribute add an index.md to the base directory of this version!
        "
      if data and data.select {|file| file[:title] == 'index.md'} then index = File.read(data[0][:path]) end
    end

    # Take an array of section objects then create the record and build the included child sections and files.
    # @method migrate_sections
    # @private
    # @param {Array} sections An array of section objects from the doc_hash
    # @param {String} version The parent version of all the sections
    # @param {Hash} parent The parent section if these sections are a child array
    def migrate_sections(sections, version, parent=nil)
      sections.each do |section|
        section_record = get_or_create_section(section, version, parent)
        if section['files'] then migrate_documents(section['files'], section_record, version) end
        if section['sections'] then migrate_sections(section['sections'], version, section_record) end
      end
    end

    # Take an array of file objects then create the record.
    # @method migrate_docuemnts
    # @private
    # @param {Array} files An array of file objects
    # @param {Hash} section The parent section of the file, if nil then file is part of the base version array.
    # @param {String} version The parent version of all the files
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

    # Takes a document object and sets the according model attributes then saving the record.
    # @method get_or_create_document
    # @private
    # @param {Hash} document The document object hash with corresponding attributes
    def get_or_create_document(document)
      order = set_order_from_title(document[:title])
      obj   = document_class.find_or_create_by(title: document[:title], section_id: document[:section_id], version_id: document[:version_id])
      document_class.find(obj) ## Hacky to generate the :slug for FriendlyId
      obj.updated_at = Time.now unless obj.body.eql? document[:body]
      obj.body  = document[:body]
      if order then obj.order = order else obj.order = nil end
      obj.save
      add_document(obj)
    end

    # Takes a version object and sets the according model attributes then saving the record.
    # @method get_or_create_document
    # @private
    # @param {String} title The version title
    # @param {String} text The versions body text from a markdown file or default.
    def get_or_create_version(title, text)
      version      = version_class.find_or_create_by(title: title)
      version.updated_at = Time.now unless version.body.eql? text
      version.body = text if text
      version.save
      add_version(version)
    end


    # Takes a version object and sets the according model attributes then saving the record.
    # @method get_or_create_document
    # @private
    # @param {Hash} section The section hash with corresponding attributes
    # @param {Object} version The version record to associate with
    # @param {Hash} parent The parent section if available
    def get_or_create_section(section, version, parent)
      order          = set_order_from_title(section[:title])
      section        = section_class.find_or_create_by(title: section[:title], version_id: version.id)
      section.parent = parent if parent
      section.order  = order if order
      section.save
      add_section(section)
    end


    # Takes a version object and sets the according model attributes then saving the record.
    # @method get_or_create_document
    # @private
    # @param {String} title Scrape the order attribute based on the title string of a file.
    def set_order_from_title(title)
      has_order = /^[0-9]?[0-9]_/.match(title)
      if has_order
        order = has_order.to_s.to_i
        title.gsub!(/^[0-9]?[0-9]_/, '')
        return order
      end
    end
  end
      
end; end; end