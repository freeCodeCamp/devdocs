module Docs
  class Falcon
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove! "\u{00B6}"
        name
      end

      def get_type
        case slug.split('/').first
        when 'user'
          'Guide'
        when 'api'
          'API'
        end
      end

      def additional_entries
        entries = []

        css('.class').each do |node|
          namespace = node.at_css('.descclassname').content.strip.remove(/\.\z/)
          class_name = node.at_css('dt > .descname').content
          class_id = node.at_css('dt[id]')['id']
          entries << ["#{namespace}.#{class_name}", class_id, namespace]

           node.css('.attribute').each do |n|
            next unless n.at_css('dt[id]')
            name = n.at_css('.descname').content
            name = "#{namespace}.#{class_name}.#{name}"
            id = n.at_css('dt[id]')['id']
            entries << [name, id, namespace]
          end

          node.css('.method').each do |n|
            next unless n.at_css('dt[id]')
            name = n.at_css('.descname').content
            name = "#{namespace}.#{class_name}.#{name}()"
            id = n.at_css('dt[id]')['id']
            entries << [name, id, namespace]
          end
        end

        css('.function').each do |node|
          namespace = node.at_css('.descclassname').content.strip.remove(/\.\z/)
          name = "#{namespace}.#{node.at_css('.descname').content}()"
          id = node.at_css('dt[id]')['id']
          entries << [name, id, namespace]
        end

        entries
      end
    end
  end
end
