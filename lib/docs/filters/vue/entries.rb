module Docs
  class Vue
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        if slug.start_with?('guide')
          'Guide'
        else
          'API'
        end
      end

      def additional_entries
        return [] if slug.start_with?('guide')

        css('h3').map do |node|
          name = node.content.strip
          name.sub! %r{\(.*\)}, '()'
          [name, node['id'], "API: #{self.name}"]
        end
      end
    end
  end
end
