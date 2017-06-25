module Docs
  class Symfony
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#page-content')

        css('.location', '.no-description').remove

        css('.page-header > h1').each do |node|
          node.content = 'Symfony' if root_page?
          node.parent.before(node).remove
        end

        css('div.details').each do |node|
          node.before(node.children).remove
        end

        css('a > abbr').each do |node|
          node.parent['title'] = node['title']
          node.before(node.children).remove
        end

        css('h1 > a', '.content', 'h3 > code', 'h3 strong', 'abbr', 'div.method-item', 'div.method-description', 'div.tags').each do |node|
          node.before(node.children).remove
        end

        css('.container-fluid').each do |node|
          html = node.inner_html
          html.gsub! %r{<div class="col[^>]+>(.+?)</div>}, '<td>\1</td>'
          html.gsub! %r{<div class="row[^>]+>(.+?)</div>}, '<tr>\1</tr>'
          node.replace("<table>#{html}</table>")
        end

        doc
      end
    end
  end
end
