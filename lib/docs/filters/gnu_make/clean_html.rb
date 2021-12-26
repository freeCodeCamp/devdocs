module Docs
  class GnuMake
    class CleanHtmlFilter < Filter
      def call

        if current_url == root_url
          # Remove short table contents
          css('.shortcontents').remove
          css('.shortcontents-heading').remove
          css('.contents-heading').remove
          css('.contents').remove
          css('.settitle').remove

          # remove copyright
          css('blockquote').remove
        end

        css('hr').remove

        css('.header').remove

        # Remove undesirable in headers
        css('.chapter', '.section', '.subsection', '.subsubsection', '.appendix').each do |node|

          node.content = node.content.slice(/[[:alpha:]]...*/)

          node.content = node.content.sub(/Appendix.{2}/, '') if node.content.include?('Appendix')

          if node.content.match?(/[[:upper:]]\./)
            node.content = node.content.sub(/[[:upper:]]\./, '')
            node.content = node.content.gsub(/\./, '')
            node.content = node.content.gsub(/[[:digit:]]/, '')
          end

          node.name = "h1"
        end

        css('dt code').each do |node|
          node.parent['id'] = node.content
        end

        css('dt > samp').each do |node|
          node.parent['id'] = node.content
        end

        css('br').remove

        css('.footnote').remove

        doc
      end
    end
  end
end
