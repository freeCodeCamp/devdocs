module Docs
  class Coffeescript
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('main')

        css('> header', '#resources', '#changelog').remove

        css('section').each do |node|
          node.first_element_child['id'] = node['id']
          node.before(node.children).remove
        end

        css('.uneditable-code-block').each do |node|
          node.before(node.children).remove
        end

        css('aside.code-example').each do |node|
          node.name = 'div'
          node['class'] = 'code'
          node.children = node.css('pre')
          node.remove_attribute('data-example')
        end

        css('.code pre:first-child').each do |node|
          node['data-language'] = 'coffeescript'
        end

        css('.code pre:last-child').each do |node|
          node['data-language'] = 'javascript'
        end

        css('pre').each do |node|
          content = node.content
          node.content = content
          unless content.start_with?('coffee ') || content.start_with?('npm ')
            node['data-language'] ||= 'coffeescript'
          end
        end

        doc
      end
    end
  end
end
