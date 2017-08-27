module Docs
  class D
    class CleanHtmlFilter < Filter
      def call
        css('.d_decl > div > span.def-anchor').each do |node|
          node.parent.parent['id'] = node['id']
        end
        doc
      end
    end
  end
end
