module Docs
  class Typescript
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        at_css('h1') ? at_css('h1').content : at_css('h2').content
      end

      def get_type
        name
      end

      def additional_entries
        entries = []

        css('h2').each do |node|

          if slug == 'tsconfig/'
            node.css('a').remove
          end

          entries << [node.content, node['id'], name]
        end

        if slug == 'tsconfig/'
          css('h3').each do |node|
            node.css('a').remove
            entries << [node.content, node['id'], name]
          end
        end

        entries
      end

    end
  end
end
