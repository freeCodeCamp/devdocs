module Docs
  class Deno
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('main, article, [role="main"], .markdown-body') || doc

        css('nav, footer, .sidebar, .breadcrumb, .toc,
             .page-nav, .edit-link, .header-anchor, script, style').remove

        css('pre > code').each do |node|
          if node['class']
            lang = node['class'][/language-(\w+)/, 1]
            node.parent['data-language'] = lang if lang
          end
          node.parent['data-language'] ||= 'typescript'
        end

        doc
      end
    end
  end
end
