module Docs
  class Meteor
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#introduction').parent

        css('.github-ribbon').remove

        css('.selflink', 'b > em').each do |node|
          node.before(node.children).remove
        end

        css('pre').each do |node|
          node['class'] = node.at_css('code')['class']
          node.content = node.content
        end

        doc
      end
    end
  end
end
