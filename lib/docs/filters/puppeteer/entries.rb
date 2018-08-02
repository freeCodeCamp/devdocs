module Docs
  class Puppeteer
    class EntriesFilter < Docs::EntriesFilter
      # The entire reference is one big page, so get_name and get_type are not necessary

      def additional_entries
        entries = []

        css('h3').each do |node|
          name = node.content.split(': ').last

          # Set the id to the id of the link in the header
          # Also remove the "user-content-" part of the id to fix internal links
          node['id'] = node.at_css('a')['id'].sub('user-content-', '')

          # Find all sub-items (all h4's between the current h3 and the next)
          current = node.next
          while !current.nil? && current.name != 'h3'
            if current.name == 'h4'
              current_name = current.content

              # Prepend events with the class name
              if current_name.start_with?('event: ')
                current_name = "#{name} event: '#{current_name[/'(.*)'/, 1]}'"
              end

              # Remove arguments from functions
              if current_name.include?('(')
                current_name = current_name.split('(')[0] + '()'
              end

              current['id'] = current.at_css('a')['id'].sub('user-content-', '')

              entries << [current_name, current['id'], name]
            end

            current = current.next
          end

          entries << [name, node['id'], name]
        end

        entries
      end
    end
  end
end
