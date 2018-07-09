module Docs
  class Leaflet
    class CleanHtmlFilter < Filter
      def call
        css('#toc', '.expander', '.footer').remove

        css('h1').each do |node|
          node.name = 'h2'
        end

        at_css('> h2:first-child').name = 'h1'

        # remove "This reference reflects Leaflet 1.2.0."
        css('h1 ~ p').each do |node|
          node.remove
          break
        end

        css('section', 'code b', '.accordion', '.accordion-overflow', '.accordion-content').each do |node|
          node.before(node.children).remove
        end

        css('pre > code').each do |node|
          node['class'] ||= ''
          lang = if node['class'].include?('lang-html') || node.content =~ /\A</
            'html'
          elsif node['class'].include?('lang-css')
            'css'
          elsif node['class'].include?('lang-js') || node['class'].include?('lang-javascript')
            'javascript'
          end
          node.parent['data-language'] = lang if lang
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
