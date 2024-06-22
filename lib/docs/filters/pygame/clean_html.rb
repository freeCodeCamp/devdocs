module Docs
  class Pygame
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.body')
        root_page? ? root : other
        doc
      end

      def root
        at_css('h1').content = 'Pygame'

        # remove unneeded stuff
        at_css('.modindex-jumpbox').remove
        css('[role="navigation"], .pcap, .cap, .footer').remove
        css('tr > td:first-child').remove

        # Unitalicize package descriptions
        css('td > em').each do |node|
          node.parent.content = node.content
        end
      end

      def other
        css('table.toc.docutils, .tooltip-content').remove

        # Remove code tag from function, class, method, module, etc.
        css('dl > dt').each do |node|
          node.content = node.content
        end

        css('> .section > dl > dt').each do |node|
          node.name = 'h1'
          node.parent.parent.before(node)
        end

        # Format code for it be highlighted
        css('.highlight-default.notranslate').each do |node|
          node.name = 'pre'
          node.content = node.content.strip
          node['class'] = 'language-python'
          node['data-language'] = 'python'
        end

      end
    end
  end
end
