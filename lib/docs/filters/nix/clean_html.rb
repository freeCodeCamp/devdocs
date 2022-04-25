module Docs
  class Nix
    class CleanHtmlFilter < Filter
      def call
        if subpath == 'nixpkgs/stable/index.html'
          new_root = Nokogiri::XML::Node.new 'div', doc.document

          # lib functions
          lib_sections = xpath("//*[@id='sec-functions-library']/ancestor::section[1]/section/section")
          lib_sections.css('.titlepage .title').each do |title|
            title.name = 'h2'
            strip_section_number(title.children)
            title['id'] = title.content.gsub(/[^a-zA-Z0-9]/, '-')
          end
          lib_sections.css('.example .title strong').each do |title|
            title.content = title.content.sub(/^Example ([0-9.]+)/, 'Example: ')
          end
          new_root.add_child(lib_sections)

          # fetchers
          fetcher_sections = xpath("//*[@id='chap-pkgs-fetchers']/ancestor::section[1]/section[position()>1]")
          fetcher_sections.css('.titlepage .title').each do |title|
            strip_section_number(title.children)
            prefix_with(title, 'pkgs') if title.name == 'h2'
          end
          new_root.add_child(fetcher_sections)

          # trivial builders
          trivial_sections = xpath("//*[@id='chap-trivial-builders']/ancestor::section[1]/section")
          trivial_sections.css('.titlepage .title').each do |title|
            strip_section_number(title.children)
            prefix_with(title, 'pkgs') if title.name == 'h2'
          end
          new_root.add_child(trivial_sections)

          # special builders
          special_sections = xpath("//*[@id='chap-special']/ancestor::section[1]/section")
          special_sections.css('.titlepage .title').each do |title|
            strip_section_number(title.children)
            if title.name == 'h2'
              title.children[0].wrap('<code>')
              prefix_with(title, 'pkgs')
            end
          end
          new_root.add_child(special_sections)

          # image builders
          image_sections = xpath("//*[@id='chap-images']/ancestor::section[1]/section")
          image_sections.css('.titlepage .title').each do |title|
            strip_section_number(title.children)
            title.children[0].wrap('<code>')
          end
          image_sections.each do |section|
            prefix = section.at_xpath('*[@class="titlepage"]//*[@class="title"]').content
            next unless ["pkgs.dockerTools", "pkgs.ociTools"].include?(prefix)
            section.xpath('section/*[@class="titlepage"]//*[@class="title"]').each do |title|
              prefix_with(title, prefix)
              title['data-add-to-index'] = ''
            end
          end
          new_root.add_child(image_sections)

          new_root.css('pre.programlisting').attr('data-language', 'nix')

          new_root
        elsif subpath == 'nix/stable/expressions/builtins.html'
          @doc = doc.at_css('main dl')

          # strip out the first entry, `derivation`, the actual documentation
          # exists in a separate page
          derivation_dt = doc.children.at_css('dt')
          if derivation_dt.content.starts_with?('derivation')
            derivation_dt.remove
            doc.children.at_css('dd').remove
          else
            raise RuntimeError.new('First entry is not derivation, update the scraper')
          end

          doc.css('dt').each do |title|
            title.name = 'h2'
            unwrap(title.at_css('a'))
            title.children[0].children.before('builtins.')
          end
          doc.css('dd').each do |description|
            description.name = 'div'
          end

          doc.css('pre > code').each do |code|
            code.parent['data-language'] = 'nix' if code['class'] == 'language-nix'
            code.parent['data-language'] = 'xml' if code['class'] == 'language-xml'
            unwrap(code)
          end

          doc
        else
          doc
        end
      end

      def strip_section_number(title_children)
        while title_children.first.content == ''
          title_children.shift.remove
        end
        first_text = title_children.first
        return unless first_text.text?
        first_text.content = first_text.content.sub(/[0-9.]+ ?/, '')
        first_text.remove if first_text.blank?
      end

      def prefix_with(title_node, text)
        title_node.css('code').each do |code|
          code.content = "#{text}.#{code.content}" unless code.content.starts_with?("#{text}.")
        end
      end

      def unwrap(node)
        node.replace(node.inner_html)
      end
    end
  end
end
