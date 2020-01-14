module Docs
  class Gnuplot
    class CleanHtmlFilter < Filter
      def call
        # remove some anchors nested inside headers: <hX><a name="">...</a></hX>
        css('h1, h2, h3, h4, h5').each do |heading|
          anchor = heading.css('a')[0]
          heading['id'] = anchor['id'] || anchor['name']
          heading.content = anchor.content.strip
        end

        # make the title on the front page which is in some weird tags
        if root_page?
          title = css('.HUGE')[0]
          title.name = 'h1'

          subtitle = css('.XLARGE')[0]
          title.content = title.content + ' − ' + subtitle.content

          css('> *:first-child')[0].before(title)
          subtitle.remove

          css('p:contains("TableOfContents")').remove
        end

        # remove nav, empty items, and any useless horizontal rules as well
        # as the subsection table of contents (.ChildLinks)
        css('.navigation').remove
        css('#CHILD_LINKS, ul.ChildLinks').remove
        css('hr').remove
        css('br').remove
        # Anchors that use only names are some numerical IDs that latex2html distributes through the document
        css('a[name]:not([href]):not([id])').remove

        # spacing
        css('> div, p').each do |node|
          node.remove if node.content.strip.empty?
        end

        css('pre').each do |node|
          node.content = dedent(node.content)
        end

        # links generated are of the form (NB: some might have been removed):
        # <B>{text} (p.&nbsp;<A HREF="{target}"><IMG  ALT="[*]" SRC="crossref.png"></A>)<A NAME="{anchor}"></A></B>
        # transform to <b><a href="{target}>{text}</a></b>
        css('b:contains(" (p. ")').each do |node|
          text = node.content.gsub /\(p\. (\[\*\])?\)/, ''

          link = node.css('a[href]')[0]
          if link
            link.content = text.strip

            node.children.each do |child|
              child.remove if child != link
            end
          else
            node.content = text.strip
          end
        end

        doc
      end

      private
      def dedent string
        lines = string.split "\n"
        indent = lines.reduce Float::INFINITY do |least, line|
          if line == ''
            least
          else
            [least, line.index(line.lstrip)].min
          end
        end
        if indent == Float::INFINITY
          string
        else
          lines
            .map { |line| line[indent..] || '' }
            .join("\n")
        end
      end
    end
  end
end
