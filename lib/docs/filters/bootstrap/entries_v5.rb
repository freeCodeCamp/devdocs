module Docs
  class Bootstrap
    class EntriesV5Filter < Docs::EntriesFilter

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
        return [] if root_page? || subpath.start_with?('getting-started')

        entries = []

        # titles
        css('h2:not(.accordion-header)', 'h3').each do |node|
          entries << [ name + ': ' + node.content, node['id']]
        end

        # methods and events
        # traverse through all '.tables' and search for a 'Method' or 'Event type' in the first <th>
        css('.table').each do |node|
          firstTh = node.at_css('th').content

          if firstTh == 'Method'
            # traverse all <tr> and search only the first <code> of each tr
            node.css('tr').each do |subnode|
              if subnode
                method = subnode.at_css('code')
                if method
                  method['id'] = method.content
                  entries << [method.content + ' (Method)', method['id']]
                end
              end
            end
          end

          if firstTh == 'Event type'
            node.css('tr').each do |subnode|
              event = subnode.at_css('code')
              if event
                event['id'] = event.content
                entries << [event.content + ' (Event)', event['id']]
              end
            end
          end

        end

        entries
      end

    end
  end
end
