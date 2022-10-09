module Docs
  class Vitest
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.sub! %r{\s*#\s*}, ''
        name
      end

      def get_type
        name = at_css('h1').content
        name.sub! %r{\s*#\s*}, ''
        name
      end

      def additional_entries
        return [] if root_page?
        css('h2[id], h3[id]').each_with_object [] do |node, entries|
          text = node.content.strip
          text.sub! %r{\s*#\s*}, ''
          next if text == 'Example'
          text.prepend "#{name}: " unless slug.starts_with?('api') || slug.starts_with?('config')
          entries << [text, node['id']]
        end
      end
    end
  end
end
