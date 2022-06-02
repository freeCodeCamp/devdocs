module Docs
  class Openjdk
    class CleanHtmlNewFilter < Filter
      def call

        if root_page?
          at_css('h1').content = "OpenJDK #{release} Documentation"
        end

        css('.header > h1').each do |node|
          node.parent.before(node).remove
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
        css('.type-signature, .member-signature').each do |node|
          node.content = node.content.sub(/\u200B/, '') # fix zero width space characters

          node.name = 'pre'
          node['class'] = 'lang-java'
          node['data-language'] = 'java'

          node.css('span').each do |subnode|
            subnode.name = 'code'
          end
        end

        # convert pseudo tables (made from div) to real tables
        css('div.caption').remove
        css('.two-column-summary > .col-constructor-name').add_class('col-first')
        css('.two-column-summary, .three-column-summary').each do |table|
          # table.previous_element.remove if table.previous_element?.classes?.include?('caption')
          table.name = 'table'
          tr = nil
          table.css('div.col-first, div.col-second, div.col-last').each do |td|
            if td.classes.include?('col-first')
              table.add_child('<tr>')
              tr = table.last_element_child
            end
            td.name = 'td'
            td.name = 'th' if td.classes.include?('table-header')
            td.remove_attribute('class')
            tr.add_child(td.remove)
          end
        end

        doc
      end
    end
  end
end
