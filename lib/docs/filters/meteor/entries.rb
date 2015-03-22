module Docs
  class Meteor
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        type = nil

        at_css('.full-api-toc').element_children.each_with_object [] do |node, entries|
          link = node.at_css('a')
          next unless link

          target = link['href'].remove('#/full/')

          case node.name
          when 'h1'
            type = node.content.strip
          when 'h2'
            if type == 'Concepts'
              entries << [node.content, target, type]
            else
              type = node.content.strip
            end
          when 'h3', 'h4'
            entries << [node.content, target, type]
          end
        end
      end
    end
  end
end
