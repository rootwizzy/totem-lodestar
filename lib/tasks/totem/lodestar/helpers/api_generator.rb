module Totem; module Lodestar; module ApiGenerator
  #
  # # api_generator.rb
  # - Type: **Rake Helper**
  #

  # ## Public
  def self.included(base)
  end
  
  # Called by the `totem:lodestar:api` task to initiate the source documentation build process. Without options this does not build any new documents, just create the corresponding API records into the database. With the given options it will build a whole new set of HTML documents from the source.
  # @method generate_api_documents
  # @public
  # @param {Boolean} build Runs the Groc to build HTML files
  # @param {Boolean} local Uses local file system instead of github remote
  def generate_api_documents(build, is_local)
    # Remove all of the current existing API records for a fresh slate so any removed repositories from the settings file will no longer exist.
    # 
    # @todo Re-factor this to check the diff of current and new repos as to reduce the margin for redundant creation.
    Totem::Lodestar::Api.destroy_all

    # To generate the API records we use the settings.yml as the source, this will be run every time the task is called to regenerate the records using the repo title.
    Settings.modules.api.repositories.each do |repo|
      create_api_record(repo)
    end

    # Invoke the Groc build process if the `build` flag as been added.
    build_groc_documents(is_local) if build
  end

  # ## Private
  private

  # Building the groc documents start first by creating a temp directory in the parent application. From this directory we will clone or copy in the repositories that will be parsed through Groc to build the source documentation.
  # @method build_groc_documents
  # @private
  # @param {Boolean} is_local Passed into the clone process to use local file system over github remote
  def build_groc_documents(is_local)
    Dir.mktmpdir(nil, Dir.pwd) do |dir|
      Dir.chdir(dir)

      # Iterate over each repository in the API block in settings then copy/clone the corresponding repo into the temp directory. After the repo is cloned, process it through the groc CLI and added to the `api` folder in the parent application.
      Settings.modules.api.repositories.each do |repo|
        clone_repo(repo, is_local)
        run_groc_cli(repo)
      end

      # After all the repositories have been generated begin the process of aggregating the behavior file (included javascript) for each repo into a singular javascript file.
      build_behavior_file
    end
  end

  # Used to take a given repo path and stage it into a temporary folder for Groc to use for building source documentation.
  # @method clone_repo
  # @private
  # @param {Object} repo The repo object passed in from the settings.yml
  # @param {Boolean} is_local The flag used to run the copy or clone statements
  def clone_repo(repo, is_local)
    if is_local
      sh "cp ~/Desktop/ember20/repos/#{repo.name} #{Dir.pwd} -r"
    else
      sh "git clone -b #{repo.branch} #{repo.url}"
    end
  end

  # Alternative clone method that uses a local ENV token to remotely curl a repository without the use of a login/password combination to github.
  # @deprecated
  # @method clone_repo_with_token
  # @private
  def clone_repo_with_token(repo)
    # Using the base OS curl use the authorization key with a locally stored ENV variable to hit a private repo. This github token is generated from their [Personal Access Tokens](https://github.com/settings/tokens). The token must provide 'Full control of private repositories'.
    #
    # The file that is pulled from the curl is a tarball from the given repository (hard corded to be from the sixthedge org).
    sh "curl -H 'Authorization: token #{ENV['GITHUB_TOKEN']}' -L https://api.github.com/repos/sixthedge/#{repo.name}/tarball > #{repo.name}.tar.gz"
    # Unzip the tarball which is named as the org-repo-commitHash then remove the tarball from the directory for iteration purposes.
    sh "tar -xvzf #{repo.name}.tar.gz"
    sh "rm #{repo.name}.tar.gz"
    # Now we must find the repo directory in question and copy and rename it to just the base repo name for groc to correctly find it while removing the extracted tarball version.
    Dir.foreach(Dir.pwd) do |dir|
      if dir.include?(repo.name)
        sh "cp #{Dir.pwd + '/' + dir} #{Dir.pwd + '/' + repo.name} -r"
        sh "rm #{Dir.pwd + '/' + dir} -r"
      end
    end
  end

  # Run the groc CLI with a set of options from the settings.yml
  # @method run_groc_cli
  # @private
  # @param {Object} repo The repo object from settings containing corresponding CLI options
  def run_groc_cli(repo)
    Dir.chdir(repo.name)
    sh "#{groc_cli(repo.options)}"
    Dir.chdir('..')
  end

  # Calls the groc CLI from the installed node_modules folder and passes it the required options.
  # @method groc_cli
  # @private
  # @param {Object} options Set of groc cli options
  def groc_cli(options)
    # Set the groc to use the installed node_modules version, this should be the custom groc made of lodestar which handles multiple repos and custom table of contents.
    bin = "../../node_modules/.bin/groc "

    # Add the options to the command string except for the glob portion which must be added at the end of the string.
    options.each do |opt|
      bin += opt[1] + " " unless opt.include?(:glob)
    end

    bin += options['glob']
  end

  # Create and aggregate the behavior file used by Groc for their ui and table of contents.
  # @method build_behavior_File
  # @private
  def build_behavior_file
    # Create the base assets folder and behavior file that will be used to scrape in each individual repos' behavior file and added to this one for the index of each project.
    #
    # At this current time this behavior file is only used at the index of each repo because the way groc links its table of contents and assets uses a relative path to their respective folder.
    create_file("behavior.js", "/api/assets")

    # Once the file has been created the `scrape_header` and `scrape_groc_helpers` are only required to be run once as these will not change between the files. The table of contents contains each individual repo tableOfContents object that must be split and aggregated into a singular array of objects.
    scrape_header
    scrape_table_of_contents
    scrape_groc_helpers
  end

  # Scan the behavior file for the initial variables and function call prior to the table of contents.
  # @method scrape_header
  # @private
  def scrape_header
    lines = []
    scan  = true

    Dir.chdir(File.join(Rails.application.root, primary_repo_path))

    File.open(Dir.pwd + '/assets/behavior.js', "r") do |file|
      file.each_line do |l| 
        lines.push(l) if scan == true

        scan = false if l.eql?("  var MAX_FILTER_SIZE, appendSearchNode, buildNav, buildTOCNode, clearFilter, clearHighlight, currentNode$, currentQuery, fileMap, focusCurrentNode, highlightMatch, moveCurrentNode, nav$, searchNodes, searchableNodes, selectNode, selectNodeByDocumentPath, setCurrentNodeExpanded, setTableOfContentsActive, toc$, toggleTableOfContents, visitCurrentNode;\n")
      end
    end

    write_file('behavior.js', "a", lines)
  end

  # Scan the file for the table of contents block of each repo's behavior file then add it to the main behavior file with correct separators.
  # @method scrape_table_of_contents
  # @private
  def scrape_table_of_contents
    files = []
    scan  = false

    # Change to the working directory `/api` where each repo has been cloned into. This way we can iterate over each repo's behavior.js to grab its tableOfConents object.
    Dir.chdir(File.join(Rails.application.root, "/api"))

    # This is the main loop that looks into each repo directory, skipping over the directory shortcuts and the generated assets folder to then open, scan and grab the contents of the file between the start and end of the tableOfContents object.
    Dir.foreach(Dir.pwd) do |repo|
      unless repo.eql?(".") or repo.eql?("..") or repo.eql?("assets")
        toc_lines = []
        Dir.chdir(File.join(Rails.application.root, '/api/', repo, 'assets'))
        File.open(Dir.pwd + '/behavior.js', "r") do |file|
          file.each_line do |line|
            scan = true if line.eql?("  tableOfContents = [\n")
            toc_lines.push(line) if scan
            scan = false if line.eql?("  ];\n")
          end
        end

        # After the tableOfContents lines have been scanned into the `toc_lines` array then remove the first and last element of the array which wrap the array.
        toc_lines.pop
        toc_lines.shift

        # Remove the first element and add the closing bracket to the collection so when inserted into the aggregated array it remains a proper collection.
        toc_lines.pop
        toc_lines.push("    },\n")

        # The `Files` array contains all the scraped modified tableOfConents.
        files.push(toc_lines)
      end
    end

    # Now that we have an 2D array of all the tableOfContents we now add back in the array wrapper that groc uses to build its table.
    files.unshift(["  tableOfContents = [\n"])
    files.push(["  ];\n"])

    # Change into the api assests directory to begin writing to the global behavior.js.
    Dir.chdir(File.join(Rails.application.root, "/api/assets"))

    File.open('behavior.js', "a") do |f|
      files.each do |toc_lines|
        toc_lines.each { |l| f.write(l) }
      end
    end
  end

  # Used to add the javascript methods required by the tableOfContents and other UI functionality by groc. Only required to be added to the global behavior.js once.
  # @method scrape_groc_helpers
  # @private
  def scrape_groc_helpers
    scan  = false
    lines = []

    Dir.chdir(File.join(Rails.application.root, primary_repo_path))

    File.open(Dir.pwd + '/assets/behavior.js', "r") do |file|
      file.each_line do |line|
        scan = true if line.eql?("  nav$ = null;\n")
        lines.push(line) if scan
      end
    end

    write_file('behavior.js', "a", lines)
  end

  # Helper method to call rails find_or_create_by on an lodestar API record
  # @method create_api_record
  # @private
  # @param {Object} repo Repo from settings file used for the title of the record
  def create_api_record(repo)
    Totem::Lodestar::Api.find_or_create_by(title: repo.name)
  end

  # Helper method to grab the first repo used by the scrape methods that only require a single instance of the behavior.js
  # @method primary_repo_path
  # @private
  def primary_repo_path
    "/api/" + Settings.modules.api.repositories.first.name
  end

  # Helper method used to create a file at a given path with read/write permissions. Deletes the file for a full re-write if it currently exists.
  # @method create_file
  # @private
  # @param {String} file The file name to create with
  # @param {String} path The path to write the file to
  def create_file(file, path)
    Dir.chdir(File.join(Rails.application.root, path))
    File.delete(file) if File.exists?(file)
    File.open(file, "w+")
    Dir.chdir(Rails.application.root)
  end

  # Helper method used to write given lines array or string to a file. File must exist before writing. Currently hard coded to write to files only in `api/assets`
  # @method write_file
  # @private
  # @param {String} file File name to write to
  # @param {String} mode File write mode. Defaults to read/write
  # @param {Array|String} lines Lines to write to the given file
  def write_file(file, mode="w+", lines)
    Dir.chdir(File.join(Rails.application.root, "/api/assets"))

    File.open(file, mode) do |f|
      if lines.kind_of?(Array)
        lines.each {|l| f.write(l)}
      else
        f.write(lines)
      end
    end
  end

end; end; end