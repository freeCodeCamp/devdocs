module Docs
  class Pug
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        if subpath.start_with?('language')
          'Language'
        elsif subpath.start_with?('api')
          'API'
        end
      end

      def additional_entries
        return [] unless slug == 'api/reference'

        css('h3').each_with_object [] do |node, entries|
          name = node.content
          name.sub! %r{\(.*\)}, '()'
          entries << [name, node['id']]
        end
      end
    end
  end
end
