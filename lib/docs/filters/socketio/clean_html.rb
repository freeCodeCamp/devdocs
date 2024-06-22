module Docs
  class Socketio
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('article .theme-doc-markdown')

        css('p > br').each do |node|
          node.remove unless node.next.content =~ /\s*\-/
        end

        css('header h1').each do |node|
          node.parent.replace(node)
        end
        css('footer', 'aside').remove

        css('.theme-doc-version-badge', '.theme-doc-toc-mobile', '.admonition-heading', '.hash-link').remove

        css('pre').each do |node|
          node.content = node.css('.token-line').map(&:content).join("\n")
          node.remove_attribute('style')
          node['data-language'] = node.content =~ /\A\s*</ ? 'html' : 'javascript'
          node.ancestors('.theme-code-block').first.replace(node)
        end

        css('.themedImage--dark_oUvU').remove

        css('*[class]').remove_attribute('class')

        doc
      end
    end
  end
end
