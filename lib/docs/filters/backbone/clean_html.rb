module Docs
  class Backbone
    class CleanHtmlFilter < Filter
      def call
        # Remove Introduction, Upgrading, etc.
        while doc.child['id'] != 'Events'
          doc.child.remove
        end

        # Remove Examples, FAQ, etc.
        while doc.children.last['id'] != 'faq'
          doc.children.last.remove
        end

        css('#faq', '.run').remove

        css('tt').each do |node|
          node.name = 'code'
        end

        css('pre').each do |node|
          node['data-language'] = 'javascript'
        end

        doc
      end
    end
  end
end
