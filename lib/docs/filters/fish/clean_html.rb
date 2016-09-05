module Docs
  class Fish
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.fish_right_bar')

        css('hr').remove

        css('h2').each do |node|
          node.name = 'h3'
        end

        css('h1').drop(1).each do |node|
          node.name = 'h2'
        end

        css('.anchor').each do |node|
          node.parent['id'] = node['id']
        end

        css('pre').each do |node|
          node['data-language'] = 'fish' # Prism may support fish in the future
          node.content = node.content
        end

        doc
      end
    end
  end
end
