module Docs
  class Cyclejs
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        title = at_css('h1')
        name = title ? title.content.strip : subpath.sub(/\.html\z/, '').titleize
        name = 'Cycle.js' if root_page?
        name = 'API Reference' if slug == 'api/index'
        name.delete_suffix! ' - source'
        name
      end

      def get_type
        slug.start_with?('api/') ? 'API' : 'Guide'
      end

      def additional_entries
        css('h2[id], h3[id]').map do |node|
          name = node.content.strip
          name.sub!(/\A#\s*/, '')
          name.sub!(/\s+#\z/, '')
          [get_name + ': ' + name, node['id']]
        end
      end
    end
  end
end
