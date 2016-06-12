module Docs
  class Angularjs
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if slug.start_with?('api')
          name = URI.unescape(slug).split('/').last
          name.remove! %r{\Ang\.}
          name << " (#{subtype})" if subtype == 'directive' || subtype == 'filter'
          name.prepend("#{type}.") unless type.starts_with?('ng ') || name == type
          name
        elsif slug.start_with?('guide')
          name = URI.decode(at_css('.improve-docs')['href'][/message=docs\(guide%2F(.+?)\)/, 1])
          name.prepend 'Guide: '
          name
        end
      end

      def get_type
        if slug.start_with?('api')
          type = slug.split('/').drop(1).first
          type << " #{subtype}s" if type == 'ng' && subtype
          type
        elsif slug.start_with?('guide')
          'Guide'
        end
      end

      def subtype
        return @subtype if defined? @subtype
        node = at_css '.api-profile-header-structure'
        data = node.content.match %r{(\w+?) in module} if node
        @subtype = data && data[1]
      end

      def additional_entries
        return [] unless slug.start_with?('api')
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
