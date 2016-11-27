module Docs
  class Haxe
    class CleanHtmlFilter < Filter
      def call
        css('.viewsource', 'hr', 'h1 > small', '.inherited-fields').remove

        css('h4 + h1').each do |node|
          node.after(node.previous_element)
        end

        css('.page-header h4', '.page-header > div').each do |node|
          node.name = 'p'
        end

        css('.page-header', '.body', '.page-header small', '.doc', '.identifier', '.inline-content p', '.fields').each do |node|
          node.before(node.children).remove
        end

        css('> h3').each do |node|
          node.name = 'h2'
        end

        css('.field > p > code:first-child:last-child').each do |node|
          next if node.next.try(:content).present?
          node = node.parent
          node.name = 'h3'
          node.inner_html = node.inner_html.squish.gsub('</span><', '</span> <')
        end

        css('.field').each do |node|
          link = node.at_css('a[name]')
          node.at_css('h3:not(:empty)')['id'] = link['name']
          link.before(link.children).remove
          node.before(node.children).remove
        end

        css('a[name]').each do |node|
          node.parent['id'] = node['name']
        end

        css('.inline-content').each do |node|
          node.name = 'p'
        end

        css('> div.indent').each do |node|
          node.name = 'blockquote'
        end

        css('p.inline-content').each do |node|
          node.name = 'div'
        end

        doc
      end
    end
  end
end
