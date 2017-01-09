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

          build_groc_assets
        end
      end

      def clone_repo(repo)
        sh "git clone -b #{repo.branch} #{repo.url}"
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

      def build_groc_assets
        build_behavior_file
        build_style_file
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
        Dir.chdir(Rails.application.root)
        Dir.chdir("api")
        Dir.chdir("ethinkspace-client")

        lines = []
        File.open(Dir.pwd + '/assets/style.css', "r") do |file|
          file.each_line do |line|
            lines.push(line) 
          end
        end

        Dir.chdir('..')
        Dir.chdir('assets')

        File.open('style.css', "w+") do |f|
          f.write(lines)
        end

        Dir.chdir(Rails.application.root)
      end

      def scrape_jquery_min
        Dir.chdir(Rails.application.root)
        Dir.chdir("api")
        Dir.chdir("ethinkspace-client")

        lines = ""
        File.open(Dir.pwd + '/assets/behavior.js', "r") do |file|
          lines = file.readlines[1]
        end

        Dir.chdir('..')
        Dir.chdir('assets')

        File.open('behavior.js', "w+") do |f|
          f.write(lines)
        end

        Dir.chdir(Rails.application.root)
      end

      def scrape_table_of_contents
        files = []
        scan = false

        Dir.chdir(Rails.application.root)
        Dir.chdir("api")
        Dir.foreach(Dir.pwd) do |repo|
          unless repo.eql?(".") or repo.eql?("..") or repo.eql?("assets")
            toc_lines = []
            Dir.chdir(repo)
            Dir.chdir('assets')
            File.open(Dir.pwd + '/behavior.js', "r") do |file|
              file.each_line do |line|
                scan = true if line.eql?("  tableOfContents = [\n")
                toc_lines.push(line) if scan
                scan = false if line.eql?("  ];\n")
              end
            end

            toc_lines.pop
            toc_lines.shift

            files.push(toc_lines)
            Dir.chdir('..')
            Dir.chdir('..')
          end
        end

        files.unshift(["  tableOfContents = [\n"])
        files.push(["  ];\n"])

        Dir.chdir('assets')
        File.open('behavior.js', "a") do |f|
          files.each do |toc_lines|
            toc_lines.each { |l| f.write(l) }
          end
        end

        Dir.chdir(Rails.application.root)
      end

      def scrape_groc_helpers
        Dir.chdir(Rails.application.root)
        Dir.chdir("api")
        Dir.chdir("ethinkspace-client")
        scan = false
        lines = []
        File.open(Dir.pwd + '/assets/behavior.js', "r") do |file|
          file.each_line do |line|
            scan = true if line.eql?("  nav$ = null;\n")
            lines.push(line) if scan
          end
        end

        Dir.chdir('..')
        Dir.chdir('assets')

        File.open('behavior.js', "a") do |f|
          lines.each {|l| f.write(l)}
        end

        Dir.chdir(Rails.application.root)
      end

    end
  end
end