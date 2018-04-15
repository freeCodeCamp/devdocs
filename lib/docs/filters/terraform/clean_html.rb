module Docs
  class Terraform
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
          # HCL isn't currently supported by Prism, Ruby syntax does an acceptable job for now
          if language = node['class'][/(hcl)/, 1]
            node['data-language'] = 'ruby'
          end
          node.content = node.content
        end

        doc
      end
    end
  end
end
