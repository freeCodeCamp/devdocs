module Docs
  class Rethinkdb
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          doc.inner_html = '<h1>ReQL command reference</h1>'
          return doc
        end

        css('header .title').each do |node|
          node.parent.replace(node)
        end

        css('.lang-selector').remove

        css('.command-syntax').each do |node|
          node.name = 'pre'
          node.inner_html = node.inner_html.gsub('</p>', "</p>\n")
        end

        css('pre').each do |node|
          node.content = node.content
        end

        css('.highlight', '> section', '.highlighter-rouge').each do |node|
          node.before(node.children).remove
        end

        css('h1').each do |node|
          next if node['class'].to_s.include?('title')
          node.name = 'h2'
        end

        doc
      end
    end
  end
end
