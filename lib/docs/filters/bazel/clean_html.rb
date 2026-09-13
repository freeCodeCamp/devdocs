module Docs
  class Bazel
    class CleanHtmlFilter < Filter

      def call
        fix_source_links
        add_legacy_anchors
        doc
      end

      private

      # The links to the Java source of a rule end in the name of the Material
      # icon the old documentation site rendered next to them, which the
      # conversion of the documentation to Markdown turned into plain text.
      # Only the links that do are rewritten: assigning to #content replaces
      # every child of the link with a text node.
      def fix_source_links
        css('a').each do |node|
          content = node.content
          node.content = content if content.sub!(/open_in_new\z/, '')
        end
      end

      # Some pages still link to the anchors of the old documentation site
      # ("#sh-tokenization"), whereas headings are now given an anchor derived
      # from their text ("#bourne-shell-tokenization"). Those headings are given
      # the old anchor as well, which bazel.build doesn't do: the links are
      # broken there.
      def add_legacy_anchors
        anchors = css('[id]').map { |node| node['id'] }.to_set
        headings = css('h2, h3').index_by { |node| node.content.strip.downcase }

        css('a[href^="#"]').each do |link|
          anchor = link['href'][1..]
          next if anchor.blank? || anchors.include?(anchor)
          next unless heading = headings[link.content.strip.downcase]
          # The anchor is carried by an element wrapping the text of the heading
          # rather than by an empty one, which CleanTextFilter would remove.
          heading.inner_html = %(<span id="#{anchor}">#{heading.inner_html}</span>)
          anchors << anchor
        end
      end

    end
  end
end
