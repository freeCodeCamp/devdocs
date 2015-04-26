module Docs
  class Apache
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          doc.children = css('h1, .category')
          return doc
        end

        css('.toplang', '#quickview', '.top').remove

        css('> .section', '#preamble', 'a[href*="dict.html"]', 'code var', 'code strong').each do |node|
          node.before(node.children).remove
        end

        css('p > code:first-child:last-child', 'td > code:first-child:last-child').each do |node|
          next if node.previous.try(:content).present? || node.next.try(:content).present?
          node.inner_html = node.inner_html.squish.gsub(/<br(\ \/)?>\s*/, "\n")
          node.content = node.content.strip
          node.name = 'pre' if node.content =~ /\s/
          node.parent.before(node.parent.children).remove if node.parent.name == 'p'
        end

        css('code').each do |node|
          node.inner_html = node.inner_html.squish
        end

        css('.note h3', '.warning h3').each do |node|
          node.before("<p><strong>#{node.inner_html}</strong></p>").remove
        end

        css('h2:not([id]) a[id]:not([href])').each do |node|
          node.parent['id'] = node['id']
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
