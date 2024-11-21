module Docs
  class Yarn
    class CleanHtmlBerryFilter < Filter
      def call
        @doc = at_css('main .container div.theme-doc-markdown.markdown')

        css('*').each do |node|
          node.remove_attribute('style')
        end

        css('pre').each do |node|
          lang = node['class'][/language-(\w+)/, 1]
          node['data-language'] = lang if lang
          node.content = node.css('.token-line').map(&:content).join("\n")
        end

        doc
      end
    end
  end
end
