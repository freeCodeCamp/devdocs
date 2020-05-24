module Docs
  class Ocaml
    class CleanHtmlFilter < Filter
      def call
        css('pre').each do |node|
          node['data-language'] = 'ocaml'
        end

        css('.caml-input').each do |node|
          node.content = '# ' + node.content.strip
        end

        css('.caml-example').each do |node|
          node.name = 'pre'
          node.traverse { |n| n.remove if n.text? && n.text !~ /\S/ }

          node['data-language'] = 'ocaml'
        end

        doc
      end
    end
  end
end
