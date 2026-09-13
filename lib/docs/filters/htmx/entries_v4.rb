module Docs
  class Htmx
    class EntriesV4Filter < Docs::EntriesFilter
      TYPES = {
        'docs' => 'Guides',
        'extensions' => 'Extensions',
        'reference/attributes' => 'Attributes',
        'reference/config' => 'Config',
        'reference/events' => 'Events',
        'reference/headers' => 'Headers',
        'reference/methods' => 'Methods',
        'reference/tags' => 'Tags',
      }

      def get_name
        at_css('h1')&.content&.strip.presence || super
      end

      def get_type
        # every path ends with a slash (see options[:trailing_slash])
        TYPES.each_pair { |prefix, type| return type if slug.start_with?("#{prefix}/") }
        'Reference'
      end

      # The root page holds the whole guide; make its chapters navigable.
      def additional_entries
        return [] unless root_page?
        css('article h2[id]').map { |node| [node.content.strip, node['id'], 'Guides'] }
      end
    end
  end
end
