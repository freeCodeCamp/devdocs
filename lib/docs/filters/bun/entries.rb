module Docs
  class Bun
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1') ? at_css('h1').content : at_css('h2').content
        name
      end

      def get_type
        slug.split('/').first
      end

      def additional_entries
        if slug.start_with?('pm/cli')
          css('h2[id]').each_with_object [] do |node, entries|
            name = get_name + " " + node.content.strip
            entries << [name, node['id']]
          end
        elsif slug.start_with?('runtime')
          css('h2[id]').each_with_object [] do |node, entries|
            name = get_name + ": " + node.content.strip
            entries << [name, node['id']]
          end
        else
          []
        end
      end
    end
  end
end
