module Docs
  class Elixir
    class CleanHtmlFilter < Filter
      def call

        # Strip h1 content
        css('h1').each do |node|
          node.content = node.content.strip
        end

        # Make subtitles smaller
        css('h2').each do |node|
          node.name = 'h4'
        end

        # Remove footer
        at_css('footer').remove

        # Remove behaviour after module name
        css('h1').each do |node|
          if !(node.has_attribute?('id'))
            node.content = node.content.split(" ")[0]
          end
        end

        # Remove links from summary headings
        css('.summary > h4 > a').each do |node|
          node.delete('href')
        end

        # Add elixir class to each pre for syntax highlighting
        css('pre').each do |node|
          node['class'] = "elixir"
        end

        # Rewrite .detail -> .method-detail
        css('.detail').each do |node|
          node['class'] = "method-detail"
        end

        # Change .detail-header to h3
        css('.detail-header .signature').each do |node|
          node.name = 'h3'
        end

        doc
      end
    end
  end
end
