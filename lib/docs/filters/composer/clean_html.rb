module Docs
  class Composer
    class CleanHtmlFilter < Filter
      def call
        # Remove unneeded elements
        css('#searchbar, .toc, .fork-and-edit, .anchor').remove

        # Fix the home page titles
        if subpath == ''
          css('h1').each do |node|
            node.name = 'h2'
          end

          # Add a main title before the first subtitle
          at_css('h2').before('<h1>Composer</h1>')
        end

        # Code blocks
        css('pre').each do |node|
          code = node.at_css('code[class]')

          unless code.nil?
            node['data-language'] = 'javascript' if code['class'].include?('javascript')
            node['data-language'] = 'php' if code['class'].include?('php')
          end

          node.content = node.content.strip
          node.remove_attribute('class')
        end

        doc
      end
    end
  end
end
