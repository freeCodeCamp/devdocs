module Docs
  class Enzyme
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.page-inner > section')

        # Clean headers
        css('h1').each do |node|
          node.content = node.content
        end

        # Make headers on reference pages bigger
        if subpath.include?('ReactWrapper') || subpath.include?('ShallowWrapper')
          css('h4').each do |node|
            node.name = 'h2'
          end
        end

        # Make code blocks detectable by Prism
        css('pre').each do |node|
          cls = node.at_css('code')['class']

          unless cls.nil?
            node['data-language'] = cls.split('-')[1]
          end

          node.content = node.content
        end

        doc
      end
    end
  end
end
