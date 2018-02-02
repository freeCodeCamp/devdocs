module Docs
  class Jsdoc
    class CleanHtmlFilter < Filter
      def call
        css('h2').each do |node|
          next unless node.content.strip == 'Table of Contents'
          toc_ul = node.next_element
          toc_block = node.add_next_sibling('<nav class="_toc" role="directory"></nav>').first

          node.name = 'h3'
          node['class'] = '_toc-title'
          node.remove
          toc_block.add_child(node)

          toc_ul.remove
          toc_ul['class'] = '_toc-list'
          toc_ul.css('ul').each do |child_list|
            child_list.remove
          end
          toc_block.add_child(toc_ul)
        end

        css('.prettyprint').each do |node|
          match = /lang-(\w+)/.match(node['class'])
          next unless match

          lang = match[1]
          node.remove_attribute('class')
          node['data-language'] = lang
        end

        css('figure').each do |node|
          caption = node.at_css 'figcaption'
          next unless caption

          node.children.last.add_next_sibling(caption)
        end

        doc
      end
    end
  end
end
