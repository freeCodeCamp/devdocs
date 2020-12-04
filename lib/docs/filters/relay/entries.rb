module Docs
  class Relay
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        if slug == 'index'
          return 'Relay'
        end

        at_css('h1').content
      end

      def get_type
        if slug == 'index'
          return 'Relay'
        end

        at_css('h1').content
      end

      def additional_entries
        entries = []

        if slug == 'index'
          return entries
        end

        ## avoid adding non-desired entries removing tags
        # remove header which contains a <h2> tag
        css('.fixedHeaderContainer').remove

        # remove table of content whose title is an <h2> tag
        css('.toc').remove
        ##

        css('h2, h3').each do |node|
          next if node.content.include?('Argument')
          entry_name = node.content

          if entry_name.include?('(')
            entry_name = entry_name.match(/.*\(/)[0] + ')'
          end

          entry_id = node.content.gsub(/\s/, '-').downcase
          entries << [entry_name, entry_id]
        end

        entries
      end

    end
  end
end
