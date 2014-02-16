module Docs
  class Moment
    class CleanHtmlFilter < Filter
      def call
        # Set id attributes on headings
        css('a.target').each do |node|
          node.next_element['id'] = node['name'].sub(/\A\//, '').sub(/\/\z/, '').gsub('/', '-')
        end

        css('> article', '.prose', 'h2 > a', 'h3 > a', 'pre > code').each do |node|
          node.before(node.children).remove
        end

        # Remove introduction
        doc.child.remove while doc.child['id'] != 'parsing'

        # Remove plugin list
        doc.children.last.remove while doc.children.last['id'] != 'plugins'

        css('.hash', '#plugins').remove

        doc
      end
    end
  end
end
