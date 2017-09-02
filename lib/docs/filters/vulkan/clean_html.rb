module Docs
  class Vulkan
    class CleanHtmlFilter < Filter
      def call
        # Copyright is already added via attribution option
        css('#_copyright').map do |node|
          node.parent.remove
        end

        doc
      end
    end
  end
end
