module Docs
  class Tanstack
    class EntriesFilter < Docs::EntriesFilter
      TYPES_BY_PREFIX = {
        'reference/functions/' => 'Functions',
        'reference/classes/' => 'Classes',
        'reference/interfaces/' => 'Interfaces',
        'reference/type-aliases/' => 'Type Aliases',
        'reference/variables/' => 'Variables',
        'guides/' => 'Guides',
        'guide/' => 'Guides',
        'plugins/' => 'Plugins',
        'installation/' => 'Installation',
        'routing/' => 'Routing',
        'integrations/' => 'Integrations',
        'how-to/' => 'How-to',
        'eslint/' => 'ESLint'
      }

      # Router symbol pages are titled "useNavigate hook", "Link component", etc.
      SYMBOL_TYPES = {
        'hook' => 'Hooks',
        'function' => 'Functions',
        'component' => 'Components',
        'type' => 'Types',
        'class' => 'Classes',
        'interface' => 'Interfaces'
      }

      GETTING_STARTED = %w(installation quick-start devtools faq comparison decisions-on-dx typescript graphql react-native)

      def get_name
        return 'API Reference' if page_path == 'reference/index'
        name = heading_text(at_css('h1'))
        symbol_type ? name.sub(/\s+\S+\z/, '') : name
      end

      def get_type
        return 'API Reference' if page_path == 'reference/index'
        return symbol_type || 'API' if page_path.start_with?('api/')
        TYPES_BY_PREFIX.each { |prefix, type| return type if page_path.start_with?(prefix) }
        GETTING_STARTED.include?(page_path) ? 'Getting Started' : 'Other'
      end

      def additional_entries
        return [] unless page_path.start_with?('guides/', 'guide/')

        css('.prose h2[id]').each_with_object([]) do |node, entries|
          text = heading_text(node)
          entries << ["#{name}: #{text}", node['id']] unless text.empty? || text.casecmp?('Further Reading')
        end
      end

      private

      def page_path
        @page_path ||= slug.remove(%r{\Aframework/react/})
      end

      def symbol_type
        return unless page_path.start_with?('api/router/')
        words = heading_text(at_css('h1')).split
        SYMBOL_TYPES[words.last.downcase] if words.length > 1
      end

      def heading_text(node)
        node.content.remove('#').squish
      end
    end
  end
end
