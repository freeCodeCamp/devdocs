module Docs
  class Meteor
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other

        css('pre span').each do |node|
          node.before(node.children).remove
        end

        doc
      end

      def root
        @doc = at_css('#introduction').parent

        css('.github-ribbon', '#introduction').remove

        css('.selflink', 'b > em').each do |node|
          node.before(node.children).remove
        end

        css('pre').each do |node|
          node['data-language'] = node.at_css('code')['class'].include?('html') ? 'html' : 'js'
          node.content = node.content
        end

        css('a.src-code').each do |node|
          node.content = 'Source'
        end
      end

      def other
        @doc = at_css('#content')

        css('.edit-discuss-links', '.bottom-nav', '.edit-link').remove

        css('figure.highlight').each do |node|
          node.inner_html = node.at_css('.code pre').inner_html.gsub('<br>', "\n")
          node['data-language'] = node['class'].split.last
          node.name = 'pre'
        end
      end
    end
  end
end
