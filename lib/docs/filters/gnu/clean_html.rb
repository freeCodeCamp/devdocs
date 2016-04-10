module Docs
  class Gnu
    class CleanHtmlFilter < Filter
      def call
        heading = at_css('h1, h2, h3, h4, h5')
        heading_level = heading.name[/h(\d)/, 1].to_i

        css('h2, h3, h4, h5, h6').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i - (heading_level - 1) }
        end

        css('.node > a[name]').each do |node|
          node.parent.next_element['id'] = node['name']
        end

        css('a[name]').each do |node|
          node['id'] = node['name']
        end

        css('samp > span:first-child:last-child').each do |node|
          node.parent.name = 'code'
          node.before(node.children).remove
        end

        css('pre').each do |node|
          node.inner_html = node.inner_html.strip_heredoc.strip
        end

        css('dt > em', 'acronym', 'dfn', 'cite').each do |node|
          node.before(node.children).remove
        end

        css('.node', 'br', 'hr').remove

        doc
      end
    end
  end
end
