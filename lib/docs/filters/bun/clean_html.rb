module Docs
  class Bun
    class CleanHtmlFilter < Filter
      LANGUAGE_ALIASES = {
        'js' => 'javascript',
        'jsonc' => 'json',
        'sh' => 'bash',
        'shell' => 'bash',
        'ts' => 'typescript',
        'tsx' => 'jsx'
      }

      SUPPORTED_LANGUAGES = %w(
        bash c cpp csharp css diff go html java javascript json jsx kotlin lua
        markdown nginx nix ocaml perl php python ruby rust scala scss sql
        typescript yaml zig
      )

      def call
        @doc = at_css('#docs-content')

        # The page header holds a breadcrumb and "Copy page" actions above the
        # <h1>; the footer holds prev/next pagination and "Edit on GitHub" links.
        css('nav[aria-label="Breadcrumb"]').each { |node| node.parent.remove }
        doc.element_children.each { |node| node.remove if node.name == 'footer' }

        # Tabbed sections and code groups only render the selected panel; label
        # every panel with its tab name and unhide the rest.
        css('*[role="tablist"]').each do |tablist|
          labels = tablist.css('*[role="tab"]').each_with_object({}) do |tab, memo|
            memo[tab['id']] = tab.content.strip
          end

          tablist.parent.element_children.each do |panel|
            next unless panel['role'] == 'tabpanel'
            panel.remove_attribute('hidden')
            name = labels[panel['aria-labelledby']]
            panel.prepend_child("<p><strong>#{CGI.escape_html(name)}</strong></p>") if name.present?
          end

          tablist.remove
        end

        css('pre').each do |node|
          language = node.ancestors('*[data-lang]').first.try(:[], 'data-lang')
          language = LANGUAGE_ALIASES.fetch(language, language)
          node.content = node.content
          node['data-language'] = language if SUPPORTED_LANGUAGES.include?(language)
        end

        css('a.anchor', 'button', 'svg', 'img', '.doc-icon', '*[aria-hidden="true"]').remove

        css('*[class]').each { |node| node.remove_attribute('class') }
        css('*[style]').each { |node| node.remove_attribute('style') }

        doc
      end
    end
  end
end
