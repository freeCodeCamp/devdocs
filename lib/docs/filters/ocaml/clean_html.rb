module Docs
  class Ocaml
    class CleanHtmlFilter < Filter
      def call
        css('pre').each do |node|
          node['data-language'] = 'ocaml'
        end

        doc
      end
    end
  end
end
