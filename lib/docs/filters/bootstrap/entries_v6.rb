module Docs
  class Bootstrap
    class EntriesV6Filter < Docs::EntriesFilter

      def get_name
        at_css('.bd-title').content.strip
      end

      def get_type
        type = subpath.match(/\A.*?\//).to_s[0..-2]
        type.gsub!('-', ' ')
        type.capitalize!
        type << ": #{name}" if type == 'Components'
        type
      end

      def additional_entries
        return [] if root_page? || subpath.start_with?('getting-started', 'guides')

        entries = []

        css('h2', 'h3').each do |node|
          entries << [name + ': ' + node.content.strip, node['id']] if node['id']
        end

        # methods and events
        css('table').each do |node|
          first_th = node.at_css('th')&.content
          kind = case first_th
                 when 'Method' then 'Method'
                 when 'Event', 'Event type' then 'Event'
                 end
          next unless kind

          node.css('tbody tr').each do |row|
            code = row.at_css('td code')
            next unless code
            code['id'] = code.content
            entries << ["#{name}: #{code.content} (#{kind})", code['id']]
          end
        end

        entries
      end

    end
  end
end
