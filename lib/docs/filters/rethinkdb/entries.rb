module Docs
  class Rethinkdb
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        if subpath.start_with?('api')
          name = at_css('.title').content.remove('ReQL command:').split(', ').first

          if name.strip.empty?
            'lt'
          else
            name
          end

        else
          at_css('.docs-nav .active').content
        end
      end

      def get_type
        if subpath.start_with?('api')
          link = at_css('a[href^="https://github.com/rethinkdb/docs/blob/master/api/"]')
          dir = link['href'][/api\/\w+\/([^\/]+)/, 1]
          return 'Reference' if dir == 'index.md'
          dir.titleize.gsub('Rql', 'ReQL').gsub('And', 'and')
        else
          at_css('.docs-nav .expanded').previous_element.content.prepend('Guides: ')
        end
      end

      def additional_entries
        return [] unless subpath.start_with?('api')
        at_css('.title').content.split(', ')[1..-1].map do |name|
          [name]
        end
      end

      def include_default_entry?
        at_css('.docs-article p').try(:content) != 'Choose your language:'
      end

    end
  end
end
