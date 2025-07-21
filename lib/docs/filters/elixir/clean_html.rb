module Docs
  class Elixir
    class CleanHtmlFilter < Filter
      def call
        api
        doc
      end

      def api
        css('.top-search').remove

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

            a = node.at_css('a.icon-action[title="View Source"]')
            a ||= node.at_css('a.icon-action[aria-label="View Source"]')
            source_href = a.attr('href')

            node.content = node.at_css('.signature').inner_text
            node << %(<a href="#{source_href}" class="source">Source</a>)
          end

          detail.css('.docstring h2').each do |node|
            node.name = 'h4'
          end
        end

        css('h1 a.icon-action[title="View Source"]').each do |node|
          node['class'] = 'source'
          node.content = "Source"
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
