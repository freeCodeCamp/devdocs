module Docs
  class Bluebird
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.post')

        css('hr').remove

        css('.api-code-section').each do |node|
          node.previous_element.remove
        end

        css('.post-header', '.post-content', '.api-reference-menu', '.api-code-section', 'markdown', '.highlight', 'code code').each do |node|
          node.before(node.children).remove
        end

        at_css('> h2:first-child').name = 'h1' unless at_css('h1')

        css('.header-anchor[name]').each do |node|
          node.parent['id'] = node['name']
        end

        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'javascript'
        end

        css('.info-box').each do |node|
          node.name = 'blockquote'
        end

        doc
      end
    end
  end
end
