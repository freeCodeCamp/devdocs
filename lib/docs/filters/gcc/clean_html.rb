module Docs
  class Gcc
    class CleanHtmlFilter < Filter
      def call
        css('pre').each do |node|
          node['data-language'] = 'cpp'
        end

        doc
      end
    end
  end
end
