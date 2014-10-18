module Docs
  class Lodash
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []

        css('h2').each do |node|
          type = node.content.split.first
          type.remove! %r{\W} # remove quotation marks

          node.parent.css('h3').each do |heading|
            name = heading.content
            name.sub! %r{\(.+?\)}, '()'
            entries << [name, heading['id'], type]

            if h4 = heading.parent.at_css('h4') and h4.content.strip == 'Aliases'
              h4.next_element.content.split(',').each do |n|
                entries << ["#{n.strip}()", heading['id'], type]
              end
            end
          end
        end

        entries
      end
    end
  end
end
