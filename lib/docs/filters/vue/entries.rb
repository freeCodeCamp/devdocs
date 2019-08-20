module Docs
  class Vue
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if slug == 'api/' || slug == 'api/index'
          'API'
        elsif slug == 'style-guide/'
          'Style Guide'
        else
          name = at_css('.content h1').content
          node = at_css(".sidebar .menu-root a[href='#{File.basename(slug)}']")

          return name if node.nil?

          index = node.parent.parent.css('> li > a').to_a.index(node)
          name.prepend "#{index + 1}. " if index
          name
        end
      end

      def get_type
        if slug.start_with?('guide')
          'Guide'
        elsif slug == 'style-guide/'
          'Style Guide'
        else
          'API'
        end
      end

      def additional_entries
        return [] if slug.start_with?('guide')
        type = nil

        css('.content h2, .content h3').each_with_object [] do |node, entries|
          if node.name == 'h2'
            type = node.content.strip
          else
            name = node.content.strip
            name.sub! %r{\(.*\)}, '()'
            name.sub! /(essential|strongly recommended|recommended|use with caution)\Z/, ''

            current_type = "API: #{type}"
            if slug == 'style-guide/'
              current_type = "Style Guide: "
              current_type += type.sub(/( Rules: )/, ': ').split('(')[0]
            end

            entries << [name, node['id'], current_type]
          end
        end
      end
    end
  end
end
