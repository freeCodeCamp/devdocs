module Docs
  class Vue
    class EntriesV3Filter < Docs::EntriesFilter
      def get_name
        if slug == 'api/' || slug == 'api/index'
          'API'
        elsif slug == 'style-guide/'
          'Style Guide'
        else
          name = at_css('h1').content
          name.sub! %r{#\s*}, ''
          index = css('.sidebar-link').to_a.index(at_css('.sidebar-link.active'))
          name.prepend "#{index + 1}. " if index
          name
        end
      end

      def get_type
        if slug.start_with?('guide/migration')
          'Migration'
       elsif slug.start_with?('guide')
          subtype = at_css('.sidebar-heading.open, .sidebar-link.active')
          subtype ? "Guide: #{subtype.content}": 'Guide'
        elsif slug == 'style-guide/'
          'Style Guide'
        else
          'API'
        end
      end

      def additional_entries
        return [] if slug.start_with?('guide')
        type = nil

        css('h2, h3').each_with_object [] do |node, entries|
          if node.name == 'h2'
            type = node.content.strip
            type.sub! %r{#\s*}, ''
            next if slug == 'style-guide/'
            title = at_css('h1').content.strip
            title.sub! %r{#\s*}, ''
            entries << [type, node['id'], "API: #{title}"] 
          elsif slug == 'style-guide/'
            name = node.content.strip
            name.sub! %r{#\s*}, ''
            name.sub! %r{\(.*\)}, '()'
            name.sub! /(essential|strongly recommended|recommended|use with caution)\Z/, ''
            curent_type = "Style Guide: #{type.sub(/Rules: /, ': ')}"
            entries << [name, node['id'], curent_type]
          end
        end
      end
    end
  end
end
