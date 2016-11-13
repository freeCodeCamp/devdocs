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

        css('.docs-method-edit', 'hr').remove

        css('pre').each do |node|
          if node.content =~ /\A</
            node['data-language'] = 'html'
          elsif node.content !~ /\A\d/
            node['data-language'] = 'javascript'
          end
        end

        doc
      end
    end
  end
end
