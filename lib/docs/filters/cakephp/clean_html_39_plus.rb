module Docs
  class Cakephp
    class CleanHtml39PlusFilter < Filter
      def call
        @doc = root_page? ? at_css('#content') : at_css('#right').at_css('div')

        css('a.permalink').remove

        css('.member-summary h3').each do |node|
          node.name = 'div'
          node.remove_attribute('class')
        end

        css('h6').each do |node|
          node.name = 'h4'
        end

        css('pre').each do |node|
          node.content = node.content.strip
          node['data-language'] = 'php'
        end

        # Move dummy anchor to method and property name

        css('.method-detail').each do |node|
          node.at_css('.method-name')['id'] = node.at_css('a')['id']
        end

        css('.property-detail').each do |node|
          node.at_css('.property-name')['id'] = node.at_css('a')['id']
        end

        doc
      end
    end
  end
end
