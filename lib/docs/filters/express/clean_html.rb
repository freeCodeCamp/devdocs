module Docs
  class Express
    class CleanHtmlFilter < Filter
      def call
        css('section').each do |node|
          node.before(node.children).remove
        end

        # Put id attributes on headings
        css('h2 + a[name]').each do |node|
          node.previous_element['id'] = node['name']
          node.remove
        end

        # Remove code highlighting
        css('pre').each do |node|
          node.content = node.content
        end

        doc
      end
    end
  end
end
