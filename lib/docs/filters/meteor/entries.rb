module Docs
  class Meteor
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('#content > h1').content
      end

      def get_type
        if (node = at_css('#sidebar .current')) && (node = node.ancestors('.menu-root').first.previous_element)
          "Guide: #{node.content}"
        else
          'Guide'
        end
      end

      def additional_entries
        return [] unless root_page?
        type = nil

        at_css('.full-api-toc').element_children.each_with_object [] do |node, entries|
          link = node.at_css('a')
          next unless link

          target = link['href'].remove('#/full/')

          case node.name
          when 'h1', 'h2'
            type = node.content.strip
          when 'h3', 'h4'
            entries << [node.content, target, type]
          end
        end
      end
    end
  end
end
