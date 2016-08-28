module Docs
  class Rethinkdb
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.docs-article')

        css('header .title').each do |node|
          node.parent.replace(node)
        end

        css('.lang-selector', '.platform-buttons img', 'hr', '#in-this-article').remove

        css('.command-syntax').each do |node|
          node.name = 'pre'
          node.inner_html = node.inner_html.gsub('</p>', "</p>\n")
        end

        css('pre').each do |node|
          node.content = node.content
        end

        css('.highlight', 'section', 'div.highlighter-rouge', 'a > p', 'li > h1').each do |node|
          node.before(node.children).remove
        end

        css('h2, h3, h4').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
        end

        css('h1').each do |node|
          next if node['class'].to_s.include?('title')
          node.name = 'h2'
        end

        css('td h2').each do |node|
          node.name = 'h5'
        end

        css('pre').each do |node|
          node['data-language'] = current_url.path[/\A\/api\/(\w+)\//, 1]
        end

        css('.infobox').each do |node|
          node.name = 'blockquote'
        end

        css('> .infobox:last-child:contains("Contribute:")').remove

        doc
      end
    end
  end
end
