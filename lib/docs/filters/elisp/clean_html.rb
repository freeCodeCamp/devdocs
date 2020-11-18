module Docs
  class Elisp
    class CleanHtmlFilter < Filter
      def call

        if current_url == root_url
          # remove copyright header
          css('table ~ p').remove

          # remove "Detailed Node Listing" header
          css('h2').remove

          # remove "Detailed Node Listing" table
          css('table')[1].remove

          # remove copyright
          css('blockquote').remove

          # remove index page in the index table
          css('tbody tr:last-child').remove
        end

        # remove navigation bar
        css('.header').remove

        # Remove content in headers
        css('.chapter', '.section', '.subsection', '.subsubsection', '.appendix').each do |node|

          # remove numbers at the beginning of all headers
          node.content = node.content.slice(/[[:alpha:]]...*/)

          # remove 'Appendix' word
          node.content = node.content.sub(/Appendix.{2}/, '') if node.content.include?('Appendix')

          # remove 'E.' notation for appendixes
          if node.content.match?(/[[:upper:]]\./)
            # remove 'E.'
            node.content = node.content.sub(/[[:upper:]]\./, '')
            # remove all dots (.)
            node.content = node.content.gsub(/\./, '')
            # remove all numbers
            node.content = node.content.gsub(/[[:digit:]]/, '')
          end

        end

        # add id to each defun section that contains a functions, macro, etc.
        css('dl > dt').each do |node|
          if !(node.parent.attribute('compact'))
            node['id'] = node.at_css('strong').content
          end
        end

        # remove br for style purposes
        css('br').each do |node|
          node.remove
        end

        # remove footnotes
        css('.footnote').remove

        doc
      end
    end
  end
end
