module Totem
  module Lodestar
    module ApiGenerator
      def self.included(base)
      end
        
      def generate_api_documents
        Dir.mktmpdir(nil, Dir.pwd) do |dir|
          Dir.chdir(dir)

          Settings.modules.api.repositories.each do |repo|
            clone_repo(repo)
            run_groc_cli(repo)
            create_api_record(repo)
          end

          build_behavior_file
          build_style_file
        end
      end

      private

      def primary_repo_path
        "/api/" + Settings.modules.api.repositories.first.name
      end

      def clone_repo(repo)
        sh "curl -H 'Authorization: token $TOKEN' -L https://api.github.com/repos/sixthedge/#{repo.name}/tarball > #{repo.name}.tar.gz"
        sh "tar -xvzf #{repo.name}.tar.gz"
        sh "rm #{repo.name}.tar.gz"
        Dir.foreach(Dir.pwd) do |dir|
          if dir.include?(repo.name)
            sh "cp #{Dir.pwd + '/' + dir} #{Dir.pwd + '/' + repo.name} -r"
            sh "rm #{Dir.pwd + '/' + dir} -r"
          end
        end
      end

      def run_groc_cli(repo)
        Dir.chdir(repo.name)
        sh "#{groc_cli(repo.options)}"
        Dir.chdir('..')
      end

      def create_api_record(repo)
        Totem::Lodestar::Api.find_or_create_by(title: repo.name)
      end

      def groc_cli(options)
        bin = "../../node_modules/.bin/groc "

        options.each do |opt|
          bin += opt[1] + " " unless opt.include?(:glob)
        end

        bin += options['glob']
      end

      def build_behavior_file
        create_file("behavior.js", "/api/assets")
        scrape_jquery_min
        scrape_table_of_contents
        scrape_groc_helpers
      end

      def build_style_file
        create_file("style.css", "/api/assets")
        scrape_styles
      end

      def create_file(file, path)
        Dir.chdir(File.join(Rails.application.root, path))
        File.delete(file) if File.exists?(file)
        File.open(file, "w+")
        Dir.chdir(Rails.application.root)
      end
   
      def scrape_styles
        Dir.chdir(File.join(Rails.application.root, primary_repo_path))

        lines = []
        File.open(Dir.pwd + '/assets/style.css', "r") do |file|
          file.each_line do |line|
            lines.push(line) 
          end
        end

        write_file('style.css', "w+", lines)
      end

      def scrape_jquery_min
        lines = []
        scan  = true

        Dir.chdir(File.join(Rails.application.root, primary_repo_path))

        File.open(Dir.pwd + '/assets/behavior.js', "r") do |file|
          file.each_line do |l| 
            lines.push(l) if scan == true

            scan = false if l.eql?("  var MAX_FILTER_SIZE, appendSearchNode, buildNav, buildTOCNode, clearFilter, clearHighlight, currentNode$, currentQuery, fileMap, focusCurrentNode, highlightMatch, moveCurrentNode, nav$, searchNodes, searchableNodes, selectNode, selectNodeByDocumentPath, setCurrentNodeExpanded, setTableOfContentsActive, tableOfContents, toc$, toggleTableOfContents, visitCurrentNode;\n")
          end
        end

        write_file('behavior.js', "a", lines)
      end

      def scrape_table_of_contents
        files = []
        scan  = false

        Dir.chdir(File.join(Rails.application.root, "/api"))

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

            toc_lines.pop
            toc_lines.shift

            toc_lines.pop
            toc_lines.push("    },\n")

            files.push(toc_lines)
          end
        end

        files.unshift(["  tableOfContents = [\n"])
        files.push(["  ];\n"])

        Dir.chdir(File.join(Rails.application.root, "/api/assets"))

        File.open('behavior.js', "a") do |f|
          files.each do |toc_lines|
            toc_lines.each { |l| f.write(l) }
          end
        end
      end

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

    end
  end
end