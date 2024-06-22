module Docs
  class Relay
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.post')

        header = at_css('h1')
        header.parent.before(header).remove

        css('footer').remove

        css('h2, h3').each do |node|
          node['id'] = node.at_css('a.anchor')['id']
        end

        # syntax highlight
        css('pre').each do |node|
          node['data-language'] = 'javascript'
          node.add_class('highlight')
        end

        doc
      end
    end
  end
end
