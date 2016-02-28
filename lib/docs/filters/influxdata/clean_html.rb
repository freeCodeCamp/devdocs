module Docs
  class Influxdata
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          doc.inner_html = ' '
          return doc
        end

        doc = @doc.at_css('#page-content')

        css('.page--contribute', 'hr').remove

        css('.page--body', '.page--title', 'font').each do |node|
          node.before(node.children).remove
        end

        css('pre > code').each do |node|
          node.parent['class'] = node['class']
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
