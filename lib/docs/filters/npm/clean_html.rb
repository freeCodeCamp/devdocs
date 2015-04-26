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

        css('> section', '.deep-link > a').each do |node|
          node.before(node.children).remove
        end

        css('pre.editor').each do |node|
          node.inner_html = node.inner_html.gsub(/<\/div>(?!\n|\z)/, "</div>\n")
        end

        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
