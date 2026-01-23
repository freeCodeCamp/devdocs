module Docs
  class Phpunit
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        at_css('h1').content
      end

      def get_type
        name.gsub!(/\P{ASCII}/, '')
        if name.in? ['Assertions', 'Annotations', 'The XML Configuration File']
          name.gsub('The ', '')
        else
          'Guides'
        end
      end

      def additional_entries
        return [] if type == 'Guides'

        css('h3').map do |node|
          [node.content.gsub('The ', ''), node['id']]
        end
      end
    end
  end
end
