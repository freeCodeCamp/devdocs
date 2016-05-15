module Docs
  class Phalcon
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.body')

        if root_page?
          at_css('h1').content = 'Phalcon'
        end

        css('#what-is-phalcon', '#other-formats').remove

        css('#methods > p > strong, #constants > p > strong').each do |node|
          node.parent.name = 'h3'
          node.parent['id'] = node.content.parameterize
          node.parent['class'] = 'method-signature'
          node.parent.inner_html = node.parent.inner_html.sub(/inherited from .*/, '<small>\0</small>')
        end

        css('.headerlink').each do |node|
          id = node['href'][1..-1]
          node.parent['id'] ||= id
          node.remove
        end

        css('div[class^="highlight-"]').each do |node|
          code = node.at_css('pre').content
          code.remove! %r{\A\s*<\?php\s*} unless code.include?(' ?>')
          node.content = code
          node.name = 'pre'
          node['data-language'] = node['class'][/highlight-(\w+)/, 1]
          node['data-language'] = 'php' if node['data-language'] == 'html+php'
        end

        css('.section').each do |node|
          node.before(node.children).remove
        end

        css('table[border]').each do |node|
          node.remove_attribute('border')
        end

        doc
      end
    end
  end
end
