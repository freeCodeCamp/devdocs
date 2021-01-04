module Docs
  class Openjdk
    class CleanHtmlNewFilter < Filter
      def call

        if root_page?
          at_css('h1').content = "OpenJDK #{release} Documentation"
        end

        css('.header .sub-title').remove

        css('blockquote pre').each do |node|
          node.parent.name = 'pre'
          node.parent['class'] = 'highlight'
          node.parent['data-language'] = 'java'
          node.parent.content = node.content
          node.remove
        end

        # fix ul section that contains summaries or tables
        css('ul').each do |node|
          node.css('section').each do |subnode|
            node.add_previous_sibling(subnode)
          end
        end

        doc
      end
    end
  end
end
