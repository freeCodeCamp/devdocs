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

        # Remove everything after Appendix B
        # This includes the license text, the document changelog, the compiler changelog and the footnote
        start_element = at_css('a[name="Appendix-C-_002d-GNU-Free-Documentation-License"]').previous_element
        next_element = start_element.next_element
        until start_element.nil?
          start_element.remove
          start_element = next_element
          next_element = start_element.nil? ? nil : start_element.next_element
        end

        # Make headers bigger
        css('h4').each {|node| node.name = 'h3'}

        # Remove the newlines
        # All paragraphs are inside <p> tags already anyways
        css('br').remove

        # The original document contains sub-headers surrounded by equal signs
        # Convert that to actual header elements
        css('div[align="center"]').each do |node|
          if node.content.include?('=' * 50)
            node.replace('<hr>')
          else
            node.remove_attribute('align')
            node.name = 'h4'
          end
        end

        # Remove all hr's after h4's
        css('h4').each do |node|
          next_element = node.next_element
          if !next_element.nil? && next_element.name == 'hr'
            next_element.remove
          end
        end

        doc
      end
    end
  end
end
