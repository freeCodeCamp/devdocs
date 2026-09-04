module Docs
  class Elisp
    class CleanHtmlFilter < Filter
      def call

        if current_url == root_url
          # remove the links to the Emacs website and the copyright notice
          css('#content > p').remove

          # remove the license
          css('blockquote').remove

          # remove the short table of contents, the detailed one follows it
          css('.element-shortcontents').remove

          # remove "Table of Contents" header
          css('.contents-heading').remove
        end

        # remove navigation bars and their separators
        css('.nav-panel', 'hr').remove

        # remove the "¶" links pointing at headers and definitions
        css('.copiable-link').remove

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

        # add a readable id to each definition of a function, macro, etc.
        # (the items of a plain @table have no name)
        ids = Hash.new(0)
        css('dl > dt').each do |node|
          name = node.at_css('.def-name')
          next unless name

          id = name.content
          # a few names are defined twice on the same page, e.g. as a function and as a variable
          count = ids[id] += 1
          node['id'] = count > 1 ? "#{id}-#{count}" : id
        end

        # remove br for style purposes
        css('br').each do |node|
          node.remove
        end

        # remove footnotes
        css('.footnote', '.footnotes-segment').remove

        doc
      end
    end
  end
end
