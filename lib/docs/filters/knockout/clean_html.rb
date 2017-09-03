module Docs
  class Knockout
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other

        css('pre > code').each do |node|
          node.parent['data-language'] = node.content =~ /\A\s*</ || node.content.include?('data-bind="') ? 'markup' : 'javascript'
          node.before(node.children).remove
        end

        css('pre').each do |node|
          node.content = node.content.strip_heredoc
          node['data-language'] ||= node['class'].try(:[], /brush:(.*)/, 1)
        end

        css('.highlighter-rouge').each do |node|
          node.before(node.children).remove
        end

        doc
      end

      def root
        @doc = at_css '.content'
        at_css('h1').content = 'Knockout.js'
      end

      def other
        css('h1 ~ h1').each do |node|
          node.name = 'h2'
        end

        css('.liveExample').each do |node|
          node.content = 'Live examples are not available on DevDocs, sorry.'
        end
      end
    end
  end
end
