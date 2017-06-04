module Docs
  class Electron
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1, h2').content
        name.remove! 'Class: '
        name.remove! ' Object'
        name.remove! ' Function'
        name.remove! ' Option'
        name.remove! ' Tag'
        name
      end

      def get_type
        if subpath.start_with?('tutorial') || slug.in?(%w(glossary/ faq/))
          'Guides'
        elsif subpath.start_with?('development')
          'Guides: Development'
        elsif slug.in?(%w(api/synopsis/ api/chrome-command-line-switches/))
          'API'
        elsif at_css('h1, h2').content.include?(' Object')
          'API: Objects'
        else
          name
        end
      end

      def additional_entries
        return [] unless slug.start_with?('api/')

        css('h3 > code', 'h4 > code').each_with_object [] do |node, entries|
          next if node.previous.try(:content).present? || node.next.try(:content).present?
          name = node.content
          name.sub! %r{\(.*\)}, '()'
          name.remove! 'new '
          name = "<webview #{name}>" if self.name == '<webview>' && !name.start_with?('<webview>')
          entries << [name, node.parent['id']] unless name == self.name
        end
      end

      def include_default_entry?
        slug != 'api/'
      end
    end
  end
end
