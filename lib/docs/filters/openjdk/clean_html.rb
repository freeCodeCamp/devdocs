# coding: utf-8
# frozen_string_literal: true

module Docs
  class Openjdk
    class CleanHtmlFilter < Filter
      def call
        css('.topNav', '.subNav', '.bottomNav', '.legalCopy', 'noscript', '.subTitle', 'hr').remove

        # Preserve internal fragment links
        # Transform <a name="foo"><!-- --></a><bar>text</bar>
        #      into <bar id="foo">text</bar>
        css('a[name]','a[id]').each do |node|
          if node.children.all?(&:blank?)
            node.next_element['id'] = (node['id'] || node['name'])if node.next_element
            node.remove
          end
        end

        # Remove superfluous content on package pages
        css('h2:contains("Package Specification")').each do |node|
          node.next.remove while node.next
          node.remove
        end

        # remove captions in tables
        css('table caption').each do |node|
          node.remove
        end

        css('h3[id$=".summary"]', 'h3[id$=".detail"]').each do |node|
          node.content = node.content.remove(' Summary').remove(' Detail').pluralize
        end

        if root_page? && version == '8'
          css('.header')[1].remove
          css('.contentContainer')[0].remove
          css('.contentContainer')[-1].remove

          # Remove packages not belonging to this version
          css('td.colFirst a').each do |node|
            unless context[:only_patterns].any? { |pattern| pattern =~ node['href'] }
              node.parent.parent.remove
            end
          end

        end

        if root_page?
          at_css('h1').content = "OpenJDK #{release} Documentation"
        end

        css('table').each do |node|
          node.remove_attribute 'summary'
          node.remove_attribute 'cellspacing'
          node.remove_attribute 'cellpadding'
          node.remove_attribute 'border'
        end

        css('span.deprecatedLabel').each { |node| node.name = 'strong' }

        css('.contentContainer', '.docSummary', 'div.header', 'div.description', 'div.summary', 'span', 'tbody').each do |node|
          node.before(node.children).remove
        end

        css('tt').each { |node| node.name = 'code' }
        css('div.block').each { |node| node.name = 'p' unless node.at_css('.block, p') }

        # Create paragraphs
        css('div > p:first-of-type').each do |node|
          node.before('<p></p>')
          node = node.previous
          node.prepend_child(node.previous) while node.previous
        end

        css('ul > li > table:only-child').each do |node|
          node.parent.parent.before(node)
        end

        css('blockquote > table:only-child', 'blockquote > dl:only-child').each do |node|
          node.parent.before(node).remove
        end

        css('blockquote > pre:only-child').each do |node|
          node.content = node.content.strip_heredoc
          node.parent.before(node).remove
        end

        css('blockquote > code').each do |node|
          node.parent.name = 'pre'
          node.content = node.content.strip.gsub(/\s+/, ' ')
        end

        css('dt > cite').each do |node| # remove "See The Java™ Language Specification"
          node.parent.next_element.remove
          node.parent.remove
        end

        css('dt:contains("See Also")').each do |node|
          unless node.next_element.at_css('a')
            node.next_element.remove
            node.remove
          end
        end

        css('ul.blockList li.blockList:only-child').each do |node|
          node.first_element_child['id'] ||= node.parent['id'] if node.parent['id']
          node.parent.before(node.children).remove
        end

        css('hr + br', 'p + br', 'div + br', 'hr').remove

        css('pre').each do |node|
          node.content = node.content.strip
          node['data-language'] = 'java'
        end

        css('.title').each do |node|
          node.name = 'h1'
        end

        css('h3, h4').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i - 1 }
        end

        css('*[title]').remove_attr('title')

        css('*[class]').each do |node|
          node.remove_attribute('class') unless node['class'] == 'inheritance'
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
