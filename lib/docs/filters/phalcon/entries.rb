module Docs
  class Phalcon
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        (at_css('h1 > strong') || at_css('h1')).content.strip.remove('Phalcon\\')
      end

      def get_type
        if slug.start_with?('reference')
          'Guides'
        else
          path = name.split('\\')
          path[0] == 'Mvc' ? path[0..1].join('\\') : path[0]
        end
      end

      def additional_entries
        entries = []

        css('.method-signature').each do |node|
          next if node.content.include?('inherited from') || node.content.include?('protected ') || node.content.include?('private ')
          name = node.at_css('strong').content.strip
          next if name == '__construct' || name == '__toString'
          name.prepend "#{self.name}::"
          entries << [name, node['id']]
        end

        entries
      end
    end
  end
end
