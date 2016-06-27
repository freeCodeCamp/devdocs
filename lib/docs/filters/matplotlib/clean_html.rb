module Docs
  class Matplotlib
    class CleanHtmlFilter < Filter
      def call
        css('.headerlink').each do |node|
          node.remove
        end
        doc
      end
    end
  end
end
