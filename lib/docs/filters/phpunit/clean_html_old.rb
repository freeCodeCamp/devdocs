module Docs
  class Phpunit
    class CleanHtmlOldFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        doc.inner_html = ' '
      end

      def other
        @doc = doc.at_css('div.appendix, div.chapter')

        css('.example-break', '.table-break').remove

        css('a[id]').each do |node|
          next unless node.content.blank?
          node.parent['id'] = node['id']
          node.remove
        end

        css('.titlepage').each do |node|
          title = node.at_css('h1, .title')
          title.content = title.content.remove(/(Chapter|Appendix)\s+\w+\.\s+/)
          node.before(title).remove
        end

        css('.section').each do |node|
          node.before(node.children).remove
        end

        css('[style], [border], [valign]').each do |node|
          node.remove_attribute('style')
          node.remove_attribute('border')
          node.remove_attribute('valign')
        end

        css('.warning h3', '.alert h3').each do |node|
          node.remove if node.content == 'Note'
        end

        css('p > code.literal:first-child:last-child').each do |node|
          next if node.previous_sibling && node.previous_sibling.content.present?
          next if node.next_sibling && node.next_sibling.content.present?
          node.parent.name = 'pre'
          node.parent['class'] = 'programlisting'
          node.parent.content = node.content
        end

        css('pre', '.term').each do |node|
          node.content = node.content
        end

        css('pre.programlisting').each do |node|
          node['data-language'] = 'php'
        end

        doc
      end
    end
  end
end
