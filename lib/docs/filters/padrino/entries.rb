module Docs
  class Padrino
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1, h2').content
        name.remove! 'Class: '
        name.remove! 'Module: '
      end

      def get_type
        type = name.dup
        type.remove! %r{#.+\z}
        type.split('::')[0..2].join('::')
      end

      def additional_entries
        return [] if root_page?
        require 'cgi'

        css('.summary_signature').inject [] do |entries, node|

          name = node.children[1].attributes['title'].value
          name = CGI.unescape(name)

          unless name.start_with?('_')
            name.prepend self.name
            entries << [name, self.name.gsub('::','/').downcase.strip + node.children[1].attributes['href'].value.slice(/\#.*/)] unless entries.any? { |entry| entry[0] == name }
          end

          entries
        end
      end
    end
  end
end
