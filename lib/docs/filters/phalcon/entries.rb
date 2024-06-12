module Docs
  class Phalcon
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        return 'Phalcon' if slug == 'index'
        at_css('h1').content.gsub(/\bClass\b|\bAbstract\b|\bFinal\b|Phalcon\\|\bInterface\b/i, '').strip
      end

      def get_type
        name
      end

      def additional_entries
        entries = []

        css('h1').each do |node|
          entrie_name = node.content.gsub(/\bClass\b|\bAbstract\b|\bFinal\b|Phalcon\\|\bInterface\b/i, '').strip
          next if entrie_name == name
          entries << [entrie_name, node['id'], name]
        end

        entries
      end

    end
  end
end
