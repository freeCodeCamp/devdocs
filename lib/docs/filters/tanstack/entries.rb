module Docs
  class Tanstack
    # Runs before clean_html, while the sidebar is still in the document.
    # The page title is the first h1. Footer sections are h2s outside `.prose`.
    class EntriesFilter < Docs::EntriesFilter
      FURTHER_READING = 'Further Reading'

      # Last word of a Router symbol h1, and the category it files the page under.
      SYMBOL_KINDS = {
        'hook' => 'Hooks',
        'function' => 'Functions',
        'component' => 'Components',
        'type' => 'Types',
        'class' => 'Classes',
        'interface' => 'Interfaces'
      }.freeze

      GETTING_STARTED = %w[
        installation
        quick-start
        devtools
        faq
        comparison
        decisions-on-dx
        typescript
        graphql
        react-native
      ].freeze

      def get_name
        return 'API Reference' if page_path == 'reference/index'
        return symbol_entry[:name] if symbol_page?
        heading_text(at_css('h1'))
      end

      def get_type
        path = page_path
        return 'API Reference' if path == 'reference/index'
        return reference_type(path) if path.start_with?('reference/')
        return 'Guides' if path.start_with?('guides/', 'guide/')
        return 'Plugins' if path.start_with?('plugins/')
        return 'Installation' if path.start_with?('installation/')
        return 'Routing' if path.start_with?('routing/')
        return 'Integrations' if path.start_with?('integrations/')
        return 'How-to' if path.start_with?('how-to/')
        return 'ESLint' if path.start_with?('eslint/')
        return 'API' if path == 'api/router' || path == 'api/file-based-routing'
        return symbol_entry[:type] if symbol_page?
        return 'Getting Started' if GETTING_STARTED.include?(path)

        'Other'
      end

      def additional_entries
        return [] unless page_path.start_with?('guides/', 'guide/')

        css('.prose h2').each_with_object([]) do |node, entries|
          text = heading_text(node)
          next if text.empty? || text.casecmp?(FURTHER_READING)
          next if node['id'].blank?

          entries << ["#{name}: #{text}", node['id']]
        end
      end

      private

      # Query pages are stored as `framework/react/guides/queries`. The prefix
      # is not part of the entry scheme. Router paths have no such prefix.
      def page_path
        @page_path ||= slug.sub(%r{\Aframework/react/}, '')
      end

      def symbol_page?
        page_path.start_with?('api/router/')
      end

      # `useNavigateHook` is still named `useNavigate` because the h1 is
      # "useNavigate hook". `linkOptions` ("Link options") has no kind word,
      # so it stays under API. The URL suffix is not consulted.
      def symbol_entry
        @symbol_entry ||= begin
          title = heading_text(at_css('h1'))
          words = title.split
          kind = words.last&.downcase
          if words.length > 1 && SYMBOL_KINDS.key?(kind)
            { name: words[0..-2].join(' '), type: SYMBOL_KINDS[kind] }
          else
            { name: title, type: 'API' }
          end
        end
      end

      # v5 reference pages live in a kind folder. v4 uses a flat
      # `reference/<symbol>` path; those stay under API rather than a guessed folder.
      def reference_type(path)
        case path
        when %r{\Areference/functions/} then 'Functions'
        when %r{\Areference/classes/} then 'Classes'
        when %r{\Areference/interfaces/} then 'Interfaces'
        when %r{\Areference/type-aliases/} then 'Type Aliases'
        when %r{\Areference/variables/} then 'Variables'
        else 'API'
        end
      end

      def heading_text(node)
        return '' unless node

        copy = node.dup
        copy.css('.anchor-heading-link').remove
        copy.content.gsub(/[[:space:]]+/, ' ').strip.sub(/#\z/, '').strip
      end
    end
  end
end
