module Docs
  class Vagrant
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('#inner')

        css('hr', 'a.anchor').remove

        css('.alert').each do |node|
          node.name = 'blockquote'
        end

        css('pre').each do |node|
          if language = node['class'][/(json|shell|ruby)/, 1]
            node['data-language'] = language
          end
          node.content = node.content
        end

        doc
      end
    end
  end
end
