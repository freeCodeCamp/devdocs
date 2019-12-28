require 'commonmarker'

module Docs
  class Elm < Doc
    self.name = 'Elm'
    self.slug = 'elm'
    self.type = 'elm'

    def build_pages
      index_page = {
          path: 'index',
          store_path: 'index.html',
          output: ERB.new(INDEX_PAGE_ERB).result(binding),
          entries: [Entry.new(nil, 'index', nil)]
      }

      yield index_page

      url = 'https://package.elm-lang.org/search.json'
      response = Request.run(url)
      packages = JSON.parse(response.body)
      elm_packages = packages.select { |package| package['name'].start_with? "elm/" }

      elm_packages.each do |package|
        url = "https://package.elm-lang.org/packages/#{package['name']}/latest/docs.json"
        response = Request.run(url)
        features = JSON.parse(response.body)

        features.each do |feature|
          name = feature['name']

          package_name = package['name'].sub("elm/", "").capitalize
          type = package_name

          feature_id = feature['name']

          feature_html = generate_html(feature)
          page = {
              path: feature_id,
              store_path: "#{feature_id}.html",
              output: ERB.new(PAGE_ERB).result(binding),
              entries: [Entry.new(name, feature_id, type)]
          }

          yield page
        end
      end
    end


    INDEX_PAGE_ERB = <<-HTML.strip_heredoc
      <h1>Elm</h1>
    HTML

    PAGE_ERB = <<-HTML.strip_heredoc
      <h1><%= feature['name'] %></h1>
      <%= feature_html %>
    HTML

    def get_latest_version(opts)
      get_npm_version('elm', opts)
    end

    private

    def generate_html(section)
      # a section / feature's comment represents the overall layout for the document
      layout = section['comment']

      # initially parse the layout to html
      html = md_to_html(layout)

      # identify @docs placeholders
      matches = parse_docs(layout)

      # retrieve actual documentation from the section
      docs = find_docs(section, matches)

      # replace @docs placeholders with actual documentation
      replace_docs(html, docs)
    end

    def parse_docs(layout)
      docs = []
      md_to_doc(layout).walk do |node|
        if node.type == :text
          if (match = node.string_content.match /^@docs(.*)/)
            docs.push original: match[0], items: match[1].split(",").map(&:strip)
          else
            # do nothing
          end
        else
          # do nothing
        end
      end

      docs
    end

    def find_docs(section, docs)
      docs.each do |doc|
        doc[:items].each do |item|
          info = find_doc(section, item)
          doc[item.to_sym] = info
        end
      end
      docs
    end

    # since each element in the documentation can be identified as
    # unions, aliases, values, or binops,
    # search for the actual documentation in these properties
    def find_doc(section, item)
      categories = ['unions', 'aliases', 'values', 'binops']

      # for binops, placeholders are wrapped in parentheses (),
      # but the doc id / names are not
      item.sub! "(", ""
      item.sub! ")", ""

      categories.each do |category|
        section[category].each do |categoryItem|
          if categoryItem['name'] == item

            # remove redundant type info at the beginning
            if categoryItem.key? "type"
              categoryItem["type"].gsub! "#{section["name"]}.", ""
            end

            return {type: category.to_sym, info: categoryItem}
          end
        end
      end

      nil
    end

    def replace_docs(html, docs)
      docs.each do |doc|
        info_html = ""
        doc[:items].each do |item|
          item = doc[item.to_sym]
          type = item[:type]
          info = item[:info]

          type_html = ""
          case type
          when :unions
            #unions => name, comment, args, cases
            type_html += "<div>type <span style='font-weight: 700'>#{info["name"]}</span> #{info["args"].join " "}</div>"
            info["cases"].each_with_index do |caseArg, index|
              type_html += "<div style='padding-left: 2rem;'><code>#{index.zero? ? "=" : "|"} #{caseArg[0]}</code></div>"
            end
            type_html = wrap_code_tag type_html
            type_html += generate_comment_html(info["comment"])

            info_html = type_html
          when :aliases
            #aliases => name, comment, args, type
            type_html += "<div>type alias <span style='font-weight: bold;'>#{info["name"]}</span> #{info["args"].join " "} =</div>"
            type_html += "<div>#{format_type info["type"]}</div>"
            type_html = wrap_code_tag type_html
            type_html += generate_comment_html(info["comment"])

            info_html = type_html
          when :values
            #values => name, comment, type
            type_html += "<div><span style='font-weight: bold;'>#{info["name"]}</span> : #{format_type info["type"]}</div>"
            type_html = wrap_code_tag type_html
            type_html += generate_comment_html(info["comment"])

            info_html = type_html
          when :binops
            #binops => name, comment, type
            type_html += "<div><span style='font-weight: bold;'>(#{info["name"]})</span> : #{info["type"]}</div>"
            type_html = wrap_code_tag type_html
            type_html += generate_comment_html(info["comment"])

            info_html = type_html
          else
            raise InvalidDataSource, "Only :unions, :aliases, :values, and :binops have been implemented"
          end
        end

        # quotes are sanitized by commonmarker for some reason
        sanitized_orig_placeholder = CGI::escape_html(doc[:original])

        # https://bugs.ruby-lang.org/issues/11132
        # \\' has special meaning in sub, gsub
        # html.sub! sanitized_orig_placeholder, info_html
        html_first = html[0...html.index(sanitized_orig_placeholder)]
        html_last = html[html.index(sanitized_orig_placeholder) + sanitized_orig_placeholder.length..-1]
        html = html_first + info_html + html_last
      end

      html
    end

    def md_to_html(str)
      CommonMarker.render_html(str)
    end

    def md_to_doc(str)
      CommonMarker.render_doc(str)
    end

    def generate_comment_html(comment)
      "<div style='padding-left: 2rem; margin: 1rem 0;'>#{md_to_html(comment)}</div>"
    end

    def format_type(type)
      unless type.index "{"
        return type
      end

      type.sub! "{", ""

      type_components, return_type = type.split("}").map(&:strip)
      type_components = type_components.split(",").map(&:strip)
      formatted_type = ""
      type_components.each_with_index do |component, index|
        if index.zero?
          formatted_type += "<div>{ #{component}</div>"
        else
          formatted_type += "<div>, #{component}</div>"
        end
      end
      formatted_type += "<div>}</div>"
      formatted_type += "<div>#{return_type}</div>"

      "<div style='padding-left: 2rem;'>#{formatted_type}</div>"
    end

    def wrap_code_tag(html)
      "<code style='font-size: 0.9rem'>#{html}</code>"
    end
  end
end
