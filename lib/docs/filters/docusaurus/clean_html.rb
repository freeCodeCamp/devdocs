module Docs
  class Docusaurus
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.mainContainer .post article div span')

        css('h1, h2, h3, h4, h5, h6').each do |header|
          a = header.at_css('.anchor')
          if a.present?
            header['id'] = a['id']
            a.remove
          end

          binding.irb if header.css('.hash-link').nil?

          header.css('.hash-link').remove
        end

        doc.children.before doc.document.at_css('.postHeader h1')

        css('pre').each do |node|
          code = node > 'code'
          node['data-language'] ||= code['class'][/language-(\w+)/, 1] if node['class']
          node['data-language'] ||= node['class'][/language-(\w+)/, 1] if node['class']
          node['data-language'] = 'js'
          node.content = node.content
        end

        doc
      end
    end
  end
end
