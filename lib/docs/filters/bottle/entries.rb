module Docs
  class Bottle
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove! "\u{00B6}"
        name
      end

      def get_type
        case slug
        when 'api'
          'Reference'
        when 'configuration'
          'Reference: Configuration'
        when 'stpl'
          'Reference: SimpleTemplate'
        when 'plugindev'
          'Reference: Plugin'
        else
          'Manual'
        end
      end

      def additional_entries
        entries = []

        css('.class').each do |node|
          class_name = node.at_css('dt > .descname').content
          class_id = node.at_css('dt[id]')['id']
          entries << [class_name, class_id]

          node.css('.method').each do |n|
            next unless n.at_css('dt[id]')
            name = n.at_css('.descname').content
            name = "#{class_name}::#{name}()"
            id = n.at_css('dt[id]')['id']
            entries << [name, id]
          end
        end

        css('.function').each do |node|
          name = "#{node.at_css('.descname').content}()"
          id = node.at_css('dt[id]')['id']
          entries << [name, id]
        end

        entries
      end
    end
  end
end
