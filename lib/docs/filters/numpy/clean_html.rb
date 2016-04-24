module Docs
  class Numpy
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#spc-section-body')

        css('colgroup').remove

        css('.section', 'a > em', 'dt > tt', 'dt > em', 'dt > big', 'tbody').each do |node|
          node.before(node.children).remove
        end

        css('.headerlink').each do |node|
          id = node['href'][1..-1]
          node.parent['id'] ||= id
          doc.at_css("span##{id}").try(:remove)
          node.remove
        end

        css('tt', 'span.pre').each do |node|
          node.name = 'code'
          node.content = node.content
          node.remove_attribute 'class'
        end

        css('h1', 'h2', 'h3').each do |node|
          node.content = node.content
        end

        css('p.rubric').each do |node|
          node.name = 'h4'
        end

        css('blockquote > div:first-child:last-child').each do |node|
          node.parent.before(node.parent.children).remove
          node.before(node.children).remove
        end

        css('.admonition-example').each do |node|
          title = node.at_css('.admonition-title')
          title.name = 'h4'
          title.remove_attribute 'class'
          node.before(node.children).remove
        end

        css('em.xref').each do |node|
          node.name = 'code'
        end

        css('div[class*="highlight-"]').each do |node|
          node.content = node.content.strip
          node.name = 'pre'
          node['data-language'] = node['class'][/highlight\-(\w+)/, 1]
          node['class'] = node['data-language'] # tmp
        end

        css('table[border]').each do |node|
          node.remove_attribute 'border'
        end

        doc
      end
    end
  end
end
