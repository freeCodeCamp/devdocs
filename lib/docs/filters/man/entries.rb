module Docs
  class Man
    class EntriesFilter < Docs::EntriesFilter

      @@TYPES = {}

      def get_name
        return slug.split('/').last.sub(/\.(\d[^.]*)\z/, ' (\1)') if slug.start_with?('man')
        at_css('h1').content.sub(' — Linux manual page', '')
      end

      def get_type
        build_types if slug == 'dir_by_project'
        @@TYPES[slug] or 'Linux manual page'
      end

      def build_types
        type0 = nil
        css('*').each do |node|
          if node.name == 'h2'
            type0 = node.content
          elsif node.name == 'a' and node['href'] and node['href'].start_with?('man') and type0
            # name = node.content + node.next_sibling.content
            slug0 = node['href'].remove(/\.html\z/)
            @@TYPES[slug0] = type0
          end
        end
      end

    end
  end
end
