module Docs
  class Haxe
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        at_css('h1').text.split(' ')[1]
      end

      def get_type
        object, method = *slug.split('/')
        method ? object : 'Std'
      end

      def additional_entries
        return [] if root_page?

        css('.field a > span').map do |node|
          [name + '.' + node.content, node.content, nil]
        end
      end

      def include_default_entry?
        true
      end
    end
  end
end
