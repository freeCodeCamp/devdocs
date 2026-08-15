module Docs
  class Terraform
    class CleanHtmlFilter < Filter
      # Prism doesn't ship every language the docs use; map those onto the
      # closest grammar it does know about.
      LANGUAGE_ALIASES = {
        'console' => 'shellsession',
        # HCL isn't currently supported by Prism, Ruby syntax does an acceptable job for now
        'hcl'     => 'ruby',
        'tf'      => 'ruby',
        'terraform' => 'ruby',
      }

      # Languages that carry no syntax at all.
      PLAIN_LANGUAGES = %w(documentation plaintext text txt none)

      def call
        @doc = at_css('#main')

        # Chrome that isn't part of the documentation itself.
        css('[class*="versionSwitcher"]', '[class*="copy-button"]', 'svg', 'hr').remove
        css('a[aria-label$=" permalink"]', 'a[href*="web-unified-docs/blob"]').remove

        # Lift the page title out of its wrapper divs.
        if heading = at_css('[class*="docs-page-heading_root"]')
          heading.css('h1').each { |node| node.remove_attribute('class') }
          heading.before(heading.css('h1')).remove
        end

        css('.alert').each do |node|
          node.name = 'blockquote'
        end

        css('pre').each do |node|
          if language = language_for(node)
            node['data-language'] = language
          end
          # Drop the syntax highlighting markup so that Prism can redo it.
          node.content = node.content
          node.remove_attribute('class')
          node.remove_attribute('id')
          node.remove_attribute('style')
        end

        doc
      end

      private

      # The language is declared on a wrapper around the <pre>, as "language-hcl".
      def language_for(node)
        while (node = node.parent) && node.element?
          next unless language = node['class'].to_s[/(?:\A|\s)language-([\w-]+)/, 1]
          language = language.downcase
          return nil if PLAIN_LANGUAGES.include?(language)
          return LANGUAGE_ALIASES[language] || language
        end
        nil
      end
    end
  end
end
