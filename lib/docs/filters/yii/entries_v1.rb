module Docs
  class Yii
    class EntriesV1Filter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.strip
      end

      def get_type
        css('.summaryTable td').first.content
      end

      def additional_entries
        css('.detailHeader').inject [] do |entries, node|
          name = node.child.content.strip
          name.prepend self.name + (node.next_element.content.include?('public static') ? '::' : '->')
          entries << [name, node['id']]
        end
      end
    end
  end
end
