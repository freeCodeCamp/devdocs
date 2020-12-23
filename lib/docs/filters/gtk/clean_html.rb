module Docs
  class Gtk
    class CleanHtmlFilter < Filter
      def call

        css('table#top', 'table > colgroup', 'h2.title', '.footer', 'hr', 'br').remove

        if root_page?
          css('span > a').each do |node|
            node.parent.before(node).remove
          end
        end

        if top_table = at_css('.refnamediv > table')
          top_table.css('td > p', 'td > img').each do |node|
            top_table.before(node)
          end
          top_table.remove
        end

        css('table').each do |node|
          node.remove_attribute 'border'
          node.remove_attribute 'width'
        end

        # Move anchors to general headings
        css('h2 > a[name]', 'h3 > a[name]').each do |node|
          node.parent['id'] = node['name']
        end

        # Move anchors to function/struct/enum/etc.
        css('a[name] + h2', 'a[name] + h3').each do |node|
          node['id'] = node.previous_element['name']
        end

        # Move anchors to struct and enum members
        css('td.struct_member_name', 'td.enum_member_name').each do |node|
          node['id'] = node.at_css('a[name]')['name']
        end

        # Remove surrounding table from code blocks
        css('.listing_frame').each do |node|
          node.before(at_css('.listing_code')).remove
        end

        css('.literallayout code').each do |node|
          node.name = 'pre'
        end

        # Fix code highlighting
        css('pre').each do |node|
          # If a codeblock has URLs, don't touch it
          next if node.at_css('a[href]')

          node.content = node.content

          # it's not perfect, but make a guess at language
          if node.content =~ /\<\?xml/
            node['data-language'] = 'xml'
          else
            node['data-language'] = 'c'
          end
        end

        doc
      end
    end
  end
end
