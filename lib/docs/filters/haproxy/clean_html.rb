module Docs
  class Haproxy
    class CleanHtmlFilter < Filter
      def call
        css('br, hr, .text-right, .dropdown-menu, table.summary').remove
        css('.alert-success > img[src$="check.png"]').remove
        css('.alert-error > img[src$="cross.png"]').remove

        at_css('.page-header').remove

        css('h1, h2, h3, h4').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
          node.remove_attribute('data-target')
        end

        header = at_css('.text-center')
        header.name = 'h1'
        header.content = header.at_css('h3').content

        css('small > a').each do |node|
          node.parent.content = node.content
        end

        css('.page-header').each do |node|
          node.replace node.children
        end

        css('.keyword').each do |node|
          node['id'] = node.at_css('.anchor')['name']
        end

        css('.keyword > b', '.keyword > span').each do |node|
          node.content = node.content
          node.remove_attribute('style')
        end

        css('.dropdown').each do |node|
          node.content = node.content
        end

        css('table').each do |node|
          node.keys.each do |attribute|
            node.remove_attribute(attribute)
          end
        end

        doc
      end
    end
  end
end
