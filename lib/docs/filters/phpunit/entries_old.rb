module Docs
  class Phpunit
    class EntriesOldFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        if name.in?(%w(Assertions Annotations))
          name
        else
          'Guides'
        end
      end

      def additional_entries
        return [] if type == 'Guides'

        css('h2').map do |node|
          [node.content, node['id']]
        end
      end
    end
  end
end
