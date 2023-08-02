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
        css('.hover-link', 'footer', ':not(.detail-header) > .view-source').remove

        css('h1 .settings').remove

        css('.summary').each do |node|
          node.name = 'dl'
        end

        css('.summary h2').each do |node|
          node.content = node.inner_text
          node.parent.before(node)
        end

        css('.summary-signature').each do |node|
          node.name = 'dt'
        end

        css('.summary-synopsis').each do |node|
          node.name = 'dd'
        end

        css('section.detail').each do |detail|
          id = detail['id']
          detail.remove_attribute('id')

          detail.css('.detail-header').each do |node|
            node.name = 'h3'
            node['id'] = id

            source_href = node.at_css('a.icon-action[title="View Source"]').attr('href')

            node.content = node.at_css('.signature').inner_text
            node << %(<a href="#{source_href}" class="source">Source</a>)
          end

          detail.css('.docstring h2').each do |node|
            node.name = 'h4'
          end
        end

        css('pre').each do |node|
          node['data-language'] = 'elixir'
          node.content = node.content
        end

        css('.icon-action').remove
      end
    end
  end
end
