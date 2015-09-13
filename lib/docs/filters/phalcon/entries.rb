module Docs
  class Phalcon
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        node = css('h1').first
        name = node.content.strip
        node.remove
        name
      end

      def get_type
        if slug.start_with? 'reference'
          'Guides'
        else
          'Classes'
        end
      end

      def additional_entries
        entries = []

        css('#constants strong').each do |node|
          entries << [node.content.strip, node.parent['id'], 'Constants']
        end

        css('#methods strong').each do |node|
          entries << [node.content.strip, node.parent['id'], 'Methods']
        end

        entries
      end
    end
  end
end
