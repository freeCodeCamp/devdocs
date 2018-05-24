module Docs
  class Pygame
    class CleanHtmlFilter < Filter
      def call

        @doc = at_css '.body'

        if root_page?
          # remove unneeded stuff
          at_css('.modindex-jumpbox').remove
          css('[role="navigation"],.pcap, .cap, .footer').each do |node|
            node.remove
          end
          # table -> list
          list = at_css('table')
          list.replace(list.children)
          list.name = 'ul'
          css('tr').each do |row|
            row.name = 'li'
            row['class'] = ''
          end
          return doc
        end

        # remove unwanted stuff
        # .headerlink => ¶ after links
        # .toc => table of content
        # .tooltip-content => tooltips after links to functions
        if toremove = css('table.toc.docutils, .headerlink, .tooltip-content')
          toremove.each do |node|
            node.remove
          end
        end

        # Remove wrapper .section
        section = at_css('.section')
        definition = at_css('.definition')
        definition['id'] = section['id']
        section.replace(section.children)

        # Format code for it be highlighted
        css('.highlight-default.notranslate').each do |node|
          pre = node.at_css('pre')
          node.replace(pre)
          # gets rid of the already existing syntax highlighting
          pre.inner_html = pre.inner_text
          pre['class'] = 'language-python'
          pre['data-language'] = "python"
        end

        # change descriptions of functions/attributes to blockquote
        css('.line-block').each do |node|
          node.name = 'blockquote'
        end

        # change functions
        css('.definition').each do |d|

          # the header is the function/attribute name. It might look something like
          # this:
          #   pygame.image.load()
          # It'll end up being something like this:
          #   pygame.image.load(filename) -> Surface
          #   pygame.image.load(fileobj, namehint="") -> Surface

          header = d.at_css('dt.title')
          if d['class'].include?('class') or d['class'].include?('module')
            header.name = 'h1'
            @section = header.content.strip
          else
            header.name = 'h3'
          end
          # save the original header
          initial_header = header.content.strip
          # save the real name for the entries
          header['data-name'] = initial_header
          # empty the header
          if header.name == 'h3'
            header.inner_html = ''
          end
          # to replace it with the signatures
          next_el = header.next_element
          signatures = next_el.css('.signature')
          signatures.each do |sig|
            sig.name = 'code'
            if header.name == 'h3'
              sig.parent = header
              # the signature don't contain pygame.module. I think it's better
              # to display them, as it avoids confusion with methods (have a
              # look at the pygame.Rect page)
              if initial_header.start_with?(@section)
                sig.content = @section + '.' + sig.text
              end
              # seperate the signatures on different lines.
              header.add_child "<br>"
            end
          end
        end

        doc
      end
    end
  end
end
