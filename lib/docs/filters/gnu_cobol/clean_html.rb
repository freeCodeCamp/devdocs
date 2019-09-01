module Docs
  class GnuCobol
    class CleanHtmlFilter < Filter
      def call
        # Replace the title
        at_css('.settitle').content = 'GnuCOBOL'

        # Remove the Table of Contents
        # It's huge and the DevDocs sidebar is basically a direct copy
        css('.contents, .contents-heading').remove

        # Remove the changelog
        at_css('p').remove
        at_css('ol').remove

        # Remove horizontal lines
        css('hr').remove

        # Remove acronym tags but keep the content
        css('acronym').each {|node| node.name = 'span'}

        # Remove everything after Appendix B
        # This includes the license text, the document changelog, the compiler changelog and the footnote
        current_element = at_css('a[name="Appendix-C-_002d-GNU-Free-Documentation-License"]').previous
        until current_element.nil?
          next_element = current_element.next
          current_element.remove
          current_element = next_element
        end

        # Make headers bigger
        css('h4').each {|node| node.name = 'h3'}
        css('h3.unnumberedsec').each {|node| node.name = 'h2'}

        # Remove the newlines
        # All paragraphs are inside <p> tags already anyways
        css('br').remove

        # The original document contains sub-headers surrounded by equal signs
        # Convert those to actual header elements
        css('div[align="center"]').each do |node|
          if node.content.include?('=' * 50)
            previous = node.previous_element
            if !previous.nil? && previous.name == 'div' && previous['align'] == 'center'
              previous.name = 'h4'
            end

            node.remove
          end
        end

        # Remove align="center" attributes
        css('[align="center"]').remove_attribute('align')

        # Convert tt tags into inline code blocks and remove any surrounding quotes
        css('tt').each do |node|
          node.name = 'code'

          previous_node = node.previous
          if !previous_node.nil? && previous_node.text?
            previous_node.content = previous_node.content.sub(/([^"]?")\Z/, '')
          end

          next_node = node.next
          if !next_node.nil? && next_node.text?
            next_node.content = next_node.content.sub(/\A("[^"]?)/, '')
          end
        end

        doc
      end
    end
  end
end
