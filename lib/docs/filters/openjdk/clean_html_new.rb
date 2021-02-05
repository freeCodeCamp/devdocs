module Docs
  class Openjdk
    class CleanHtmlNewFilter < Filter
      def call

        if root_page?
          at_css('h1').content = "OpenJDK #{release} Documentation"
        end

        css('.header .sub-title', 'hr', '.table-tabs').remove

        # fix ul section that contains summaries or tables
        css('ul').each do |node|
          node.css('section').each do |subnode|
            node.add_previous_sibling(subnode)
          end
        end

        css('ul.summary-list').each do |node|
          node.css('li').each do |subnode|
            subnode.name = 'div'
          end
          node.name = 'div'
        end

        # add syntax highlight to code blocks
        css('pre > code').each do |node|
          node.parent['class'] = 'lang-java'
          node.parent['data-language'] = 'java'
        end

        # add syntax highlight to each method
        css('.member-signature').each do |node|
          node.name = 'pre'
          node['class'] = 'lang-java'
          node['data-language'] = 'java'

          node.css('span').each do |subnode|
            subnode.name = 'code'
          end

        end

        doc
      end
    end
  end
end
