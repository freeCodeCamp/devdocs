module Docs
  class Esbuild
    class CleanHtmlFilter < Filter
      def call
        css('figure.bench').remove
        css('.permalink').remove
        css('.switcher').remove
        css('pre').each do |node|
          node.content = node.content
          node['data-language'] = 'javascript'
          node['data-language'] = 'sh' if node['class'] && node['class'].include?('cli')
          node['data-language'] = 'go' if node['class'] && node['class'].include?('go')
          node['class'] = nil
        end
        doc
      end
    end
  end
end
