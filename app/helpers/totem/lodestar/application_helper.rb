module Totem
  module Lodestar
    module ApplicationHelper
      def p_render(path); render File.join("totem","lodestar", path) end

      class CodeRayify < Redcarpet::Render::HTML
        def block_code(code, language)
          CodeRay.scan(code, language).div(css: :class)
        end
      end

      def markdown(text)
        # CodeRayify options are used to make code blocks with colored syntax.
        # All options passed to CodeRayify are RedCarpet Renderer options.
        # for all options see -- https://github.com/vmg/redcarpet#darling-i-packed-you-a-couple-renderers-for-lunch
        coderayified = CodeRayify.new(
          filter_html:     true, # Do not allow user inputted HTML
          hard_wrap:       true, # Insert <br> tags inside paragraphs based on orginal document
          with_toc_data:   true, # Add id anchors to each header to allow linking
        )

        # Define what Markdown extensions to use with Redcarpet
        # for all extensions see -- https://github.com/vmg/redcarpet#and-its-like-really-simple-to-use
        options = {
          disable_indented_code_blocks: true, # do not parse usual markdown code blocks with 4 spaces because we use fenced
          fenced_code_blocks:           true, # parse fenced code blocks, used in conjuction with CodeRayify
          no_intra_emphasis:            true, # do not parse emphasis inside of words such as foo_bar_baz
          autolink:                     true, # parse links even when they are not enclosed
        }

        # Create RedCarpet Markdown Renderer with all given options
        redcarpet = Redcarpet::Markdown.new(coderayified, options)
        # Via the Renderer generate HTML with the passed markdown formatted text.
        return redcarpet.render(text).html_safe
      end


      def get_toc(body)
        if body
          header_objects = []
          body.lines.each do |line|
            if line.starts_with?("#")
              match = /(?<header>^[#]{1,6})(?<title>.*)/.match(line)
              header_objects.push({level: match[:header].length.to_i, title: match[:title].strip, children: []})
            end
          end

          string = ""
          header_objects.each do |header|
            string += "<a href=##{header[:title].parameterize} class='toc_list-item h#{header[:level]}'>"
            string += header[:title]
            string += "</a>"
          end
          string
        end
      end

      def get_settings_text(var)
        Settings[:text][var]
      end

      def current_class?(link_path)
        if request.path == link_path then return 'active' else return '' end
      end
    end
  end
end
