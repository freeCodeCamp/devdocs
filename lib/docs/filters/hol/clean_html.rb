module Docs
  class Hol
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('article .theme-doc-markdown') || at_css('article')
        return doc if @doc.nil?

        css(
          '.theme-doc-breadcrumbs',
          '.theme-doc-toc-mobile',
          '.theme-doc-footer',
          '.theme-doc-version-badge',
          '.pagination-nav',
          '.theme-edit-this-page',
          '.hash-link',
          '.anchor-link',
          'button.copyButtonIcon_Lhsm',
          'button.clean-btn',
        ).remove

        css('pre').each do |node|
          lines = node.css('.token-line')
          node.content = lines.map(&:content).join("\n") if lines.any?
          node.remove_attribute('style')

          language = node['class'].to_s[/language-([a-z0-9_-]+)/i, 1]
          language ||= node.at_css('code')&.[]('class').to_s[/language-([a-z0-9_-]+)/i, 1]
          node['data-language'] = language if language

          wrapper = node.ancestors('.theme-code-block').first
          wrapper.replace(node) if wrapper
        end

        css('.table-of-contents').remove
        css('*[class]').remove_attribute('class')
        css('*[style]').remove_attribute('style')

        doc
      end
    end
  end
end
