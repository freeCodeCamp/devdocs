module Docs
  class Ocaml
    class CleanHtmlFilter < Filter
      def call

        css('pre').each do |node|
          span = node.at_css('span[id]')
          node['id'] = span['id'] if span
          node['data-type'] = "#{span.content} [#{at_css('h1').content}]" if span
          node['data-language'] = 'ocaml'
          node.content = node.content
        end

        css('.caml-input ~ .caml-output').each do |node|
          node.previous_element << "\n\n"
          node.previous_element << node.content
          node.previous_element.remove_class('caml-input')
          node.remove
        end

        css('.maintitle *[style]').each do |node|
          node.remove_attribute 'style'
        end

        css('h1').each do |node|
          node.content = node.content
          table = node.ancestors('table.center')
          table.first.before(node).remove if table.present?
        end

        css('.navbar', '#sidebar-button', 'hr').remove
        css('img[alt="Previous"]', 'img[alt="Up"]', 'img[alt="Next"]').each do |node|
          node.parent.remove
        end

        doc
      end
    end
  end
end
