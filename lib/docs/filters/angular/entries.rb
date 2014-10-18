module Docs
  class Angular
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = slug.split('/').last
        name.remove! %r{\Ang\.}
        name << " (#{subtype})" if subtype == 'directive' || subtype == 'filter'
        name.prepend("#{type}.") unless type.starts_with?('ng ') || name == type
        name
      end

      def get_type
        type = slug.split('/').first
        type << " #{subtype}s" if type == 'ng' && subtype
        type
      end

      def subtype
        return @subtype if defined? @subtype
        node = at_css '.api-profile-header-structure'
        data = node.content.match %r{(\w+?) in module} if node
        @subtype = data && data[1]
      end

      def additional_entries
        entries = []

        css('ul.defs').each do |list|
          list.css('> li[id]').each do |node|
            next unless heading = node.at_css('h3')
            name = heading.content.strip
            name.sub! %r{\(.*\);}, '()'
            name.prepend "#{self.name.split.first}."
            entries << [name, node['id']]
          end
        end

        entries
      end
    end
  end
end
