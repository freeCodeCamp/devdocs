module Docs
  class Npm
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          css('#enterprise', '#policies', '#viewAll').remove
        else
          @doc = doc.at_css('#page')
          css('meta', '.colophon').remove
        end

        css('a.deep-link[id]', 'a.anchor[id]').each do |node|
          node.parent['id'] = node['id']
          node.remove
        end

        css('> section').each do |node|
          node.before(node.children).remove
        end

        css('pre.editor').each do |node|
          node.inner_html = node.inner_html.gsub(/<\/div>(?!\n|\z)/, "</div>\n")
        end

        css('h1 + h1.subtitle').each do |node|
          node.name = 'p'
          node.inner_html += '.'
        end

        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
