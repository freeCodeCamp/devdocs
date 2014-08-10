module Docs
  class Moment
    class CleanHtmlFilter < Filter
      def call
        # Set id attributes on headings
        css('a.docs-section-target', 'a.docs-method-target').each do |node|
          node.next_element['id'] = node['name'].remove(/\A\//).remove(/\/\z/).gsub('/', '-')
          node.remove
        end

        css('> article', '.docs-method-prose', '.docs-method-signature', 'h2 > a', 'h3 > a', 'pre > code').each do |node|
          node.before(node.children).remove
        end

        # Remove introduction
        doc.child.remove while doc.child['id'] != 'parsing'

        # Remove plugin list
        doc.children.last.remove while doc.children.last['id'] != 'plugins'

        css('.docs-method-edit', '#plugins').remove

        doc
      end
    end
  end
end
