module Docs
  class Composer
    class CleanHtmlFilter < Filter
      def call
        # Remove unneeded elements
        css('#searchbar, .toc, .fork-and-edit, .anchor').remove

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
