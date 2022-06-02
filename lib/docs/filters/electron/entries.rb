module Docs
  class Electron
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        return 'API' if subpath == '/api'

        name = at_css('h1, h2').content
        name.remove! 'Class: '
        name.remove! ' Object'
        name.remove! ' Function'
        name.remove! ' Option'
        name.remove! ' Tag'
        name
      end

      def get_type
        return 'API' if subpath == '/api'

        if subpath.start_with?('/tutorial') || subpath.in?(%w(/glossary /faq))
          'Guides'
        elsif subpath.start_with?('/development')
          'Guides: Development'
        elsif subpath.in?(%w(/api/synopsis /api/chrome-command-line-switches))
          'API'
        elsif at_css('h1, h2').content.include?(' Object')
          'API: Objects'
        else
          name
        end
      end

      def additional_entries
        return [] unless subpath.start_with?('/api')

        css('h3 > code', 'h4 > code').each_with_object [] do |node, entries|
          name = node.content
          name.sub! %r{\(.*\)}, '()'
          name.remove! 'new '
          name = "<webview #{name}>" if self.name == '<webview>' && !name.start_with?('<webview>')
          entries << [name, node.parent['id']] unless name == self.name
        end
      end
    end
  end
end
