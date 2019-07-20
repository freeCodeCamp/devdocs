module Docs
  class Elixir
    class CleanHtmlFilter < Filter
      def call
        if current_url.path.start_with?('/getting-started')
          guide
        else
          api
        end
        doc
      end

      def guide
        @doc = at_css('#content article')

        css('pre > code').each do |node|
          node.parent.content = node.content
        end

        css('div > pre.highlight').each do |node|
          node.content = node.content
          node['data-language'] = node.parent['class'][/language-(\w+)/, 1]
          node.parent.before(node).remove
        end
      end

      def api
        css('footer', '.view-source', 'h1 .visible-xs').remove

        css('section section.docstring h2').each do |node|
          node.name = 'h4'
        end

        css('h1 .hover-link', '.detail-link').each do |node|
          node.parent['id'] = node['href'].remove('#')
          node.remove
        end

        css('.details-list').each do |list|
          type = list['id'].remove(/s\z/) if list['id']
          list.css('.detail-header').each do |node|
            node.name = 'h3'
            node['class'] += " #{type}" if type
          end
        end

        css('.summary h2').each { |node| node.parent.before(node) }
        css('.summary').each { |node| node.name = 'dl' }
        css('.summary-signature').each { |node| node.name = 'dt' }
        css('.summary-synopsis').each { |node| node.name = 'dd' }

        css('section', 'div:not(.type-detail)', 'h2 a').each do |node|
          node.before(node.children).remove
        end

        css('.detail-header > pre').each do |node|
          node.parent.after(node)
        end

        css('pre').each do |node|
          node['data-language'] = 'elixir'
          node.content = node.content
        end
      end
    end
  end
end
