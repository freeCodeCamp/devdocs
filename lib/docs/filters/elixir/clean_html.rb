module Docs
  class Elixir
    class CleanHtmlFilter < Filter
      def call
        at_css('footer', '.view-source').remove

        css('section section.docstring h2').each do |node|
          node.name = 'h4'
        end

        css('h1 .hover-link', '.detail-link').each do |node|
          node.parent['id'] = node['href'].remove('#')
          node.remove
        end

        css('.details-list').each do |list|
          type = list['id'].remove(/s\z/)
          list.css('.detail-header').each do |node|
            node.name = 'h3'
            node['class'] += " #{type}"
          end
        end

        css('.summary h2').each { |node| node.parent.before(node) }
        css('.summary').each { |node| node.name = 'dl' }
        css('.summary-signature').each { |node| node.name = 'dt' }
        css('.summary-synopsis').each { |node| node.name = 'dd' }

        css('section', 'div:not(.type-detail)', 'h2 a').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
