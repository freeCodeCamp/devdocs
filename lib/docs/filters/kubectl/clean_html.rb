module Docs
  class Kubectl
    class CleanHtmlFilter < Filter

      def call
        css('pre').each do |node|
          node.content = node.content.squish
          node['data-language'] = 'bash'
        end
        doc
      end

    end
  end
end
