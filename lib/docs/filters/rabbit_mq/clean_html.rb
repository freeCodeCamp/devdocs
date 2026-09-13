module Docs
  class RabbitMq
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.theme-doc-markdown.markdown')

        css('.theme-admonition svg').remove

        css('pre').each do |node|
          node.content = node.css('.token-line').map(&:content).join("\n")

          node['data-language'] =
            if node['class'].include?('language-bash')
              'bash'
            elsif node['class'].include?('language-java')
              'java'
            end
        end

        doc
      end
    end
  end
end
