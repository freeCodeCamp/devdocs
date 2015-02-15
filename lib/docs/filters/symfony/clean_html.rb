module Docs
  class Symfony
    class CleanHtmlFilter < Filter
      def call
        css('.location', '#footer').remove

        css('.header > h1').each do |node|
          node.content = 'Symfony' if root_page?
          node.parent.before(node).remove
        end

        css('div.details').each do |node|
          node.before(node.children).remove
        end

        css('a > abbr').each do |node|
          node.parent['title'] = node['title']
          node.before(node.children).remove
        end

        css('h1 > a', '.content', 'h3 > code', 'h3 strong', 'abbr').each do |node|
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
