module Docs
  class Angular
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = slug.split(':').last
        name.sub! %r{\Ang\.}, ''
        name << " (#{subtype})" if subtype == 'directive' || subtype == 'filter'
        name
      end

      def get_type
        type = slug.split('.').first
        type << " #{subtype}s" if type == 'ng' && subtype
        type
      end

      def subtype
        return @subtype if defined? @subtype
        node = at_css 'h1'
        data = node.content.match %r{\((.+) in module} if node
        @subtype = data && data[1]
      end

      def additional_entries
        entries = []

        css('ul.defs').each do |list|
          list.css('> li > h3:first-child').each do |node|
            name = node.content.strip
            name.sub! %r{\(.+\)}, '()'
            name.prepend "#{self.name.split.first}."
            entries << [name, node['id']]
          end
        end

        entries
      end
    end
  end
end
