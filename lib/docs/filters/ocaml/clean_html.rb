module Docs
  class Ocaml
    class CleanHtmlFilter < Filter
      def call

        css('pre, .caml-example').each do |node|
          span = node.at_css('span[id]')
          node['id'] = span['id'] if span
          node['data-type'] = "#{span.content} [#{at_css('h1').content}]" if span
          node['data-language'] = 'ocaml'
          node.name = 'pre'
          node.content = node.content
        end

        css('.caml-input').each do |node|
          node.content = '# ' + node.content.strip
        end

        css('.maintitle *[style]').each do |node|
          node.remove_attribute 'style'
        end

        css('h1').each do |node|
          node.content = node.content
          table = node.ancestors('table.center')
          table.first.before(node).remove if table.present?
        end

        css('.navbar').remove

        doc
      end
    end
  end
end
