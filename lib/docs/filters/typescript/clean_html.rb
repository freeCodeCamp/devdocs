module Docs
  class Typescript
    class CleanHtmlFilter < Filter

      LANGUAGE_REPLACE = {
        'cmd' => 'shell',
        'sh' => 'shell',
        'tsx' => 'typescript+html'
      }

      def call
        @doc = at_css('main')
        root_page? ? root : other
        doc
      end

      def root
        header = at_css('h1')
        header.parent.before(header).remove

        # css('#above-the-fold-headline-code').remove
        # css('#adopt-gradually-content').remove

        css('h4').each do |node|
          node.name = 'h2'
        end
      end

      def other
        if base_url.path == '/docs/handbook/'
          deprecated = at_css('#deprecated-content')
          deprecated.css('h3', '#deprecated-icon').remove if deprecated
          deprecated.add_class('deprecated') if deprecated
          @doc = at_css('article > .whitespace > .markdown')
          doc.child.before(deprecated) if deprecated
        else # tsconfig page
        end

        css('.anchor', 'a:contains("Try")', 'h2 a', 'h3 a', 'svg', '#full-option-list').remove

        # tsconfig page
        css('.markdown', '.compiler-option', '.compiler-option-md', '.compiler-content').each do |node|
          node.remove_attribute('class')
        end

        css('pre').each do |node|
          language = node.at_css('.language-id') ? node.at_css('.language-id').content : 'typescript'
          node.css('.language-id').remove
          if node.at_css('.line').nil?
            node.content = node.content
          else
            node.content = node.css('.line').map(&:content).join("\n")
          end
          node['data-language'] = LANGUAGE_REPLACE[language] || language
          node.remove_attribute('class')
          node.remove_attribute('style')
        end
      end

    end
  end
end
