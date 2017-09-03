module Docs
  class Lua
    class CleanHtmlFilter < Filter
      def call
        css('hr', 'h1 img', '.footer').remove

        css('[name]').each do |node|
          node['id'] = node['name']
          node.remove_attribute('name')
        end

        css('h1 > a[id]', 'h2 > a[id]', 'h3 > a[id]').each do |node|
          node.parent['id'] = node['id']
          node.before(node.children).remove
        end

        css('b > code').each do |node|
          node.parent.before(node.parent.children).remove
        end

        3.times { at_css('h1[id="1"]').previous_element.remove }

        css('.apii').each do |node|
          node.parent.previous_element << node
        end

        css('pre').each do |node|
          node.content = node.content.remove(/\A\s*\n/).rstrip.strip_heredoc
          node['data-language'] = 'lua'
        end

        doc
      end
    end
  end
end
