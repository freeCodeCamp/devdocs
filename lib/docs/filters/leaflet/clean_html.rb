module Docs
  class Leaflet
    class CleanHtmlFilter < Filter
      def call
        css('#toc', '.expander', '.footer').remove

        css('h1').each do |node|
          node.name = 'h2'
        end

        # remove "This reference reflects Leaflet"
        css('p:contains("This reference reflects Leaflet")').each do |node|
          node.remove
          break
        end

        at_css('> h2:first-child').name = 'h1'

        css('section', 'code b', '.accordion', '.accordion-overflow', '.accordion-content').each do |node|
          node.before(node.children).remove
        end

        css('pre > code').each do |node|
          node['class'] ||= ''
          lang = if node['class'].include?('lang-html') || node['class'].include?('language-html') || node.content =~ /\A</
            'html'
          elsif node['class'].include?('lang-css') || node['class'].include?('language-css')
            'css'
          elsif node['class'].include?('lang-js') || node['class'].include?('language-js') || node['class'].include?('lang-javascript')
            'javascript'
          else
            'javascript'
          end
          node.parent['data-language'] = lang
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
