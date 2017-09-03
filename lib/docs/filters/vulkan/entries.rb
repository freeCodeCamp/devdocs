module Docs
  class Vulkan
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        css('.sect1').each_with_object [] do |node, entries|
          type = node.at_css('h2').content

          node.css('h3').each do |n|
            entries << [n.content, n['id'], type]
          end
        end
      end
    end
  end
end
