module Docs
  class Q
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []

        type = ''
        entry = []
        css('h3, h4, em:contains("Alias")').each do |node|

          if node.name == 'h3'
            type = node.content.strip

            if type == "Q.defer()" # Q.defer() is a method, but it also plays a section title role.
              entries << ['Q.defer', 'qdefer', 'Q.defer()']
            end
            next
          end

          if node.name == 'h4'
            name = node.content.strip.remove(/\(.*?\).*/)
            link = node['id']
            entry = [name, link, type]

            entries << entry
            next
          end

          if node.name == 'em' # for the aliases
            aliasEntry = entry.clone
            aliasEntry[0] = node.parent.at_css('code').content
            entries << aliasEntry
            next
          end

        end

        entries
      end
    end
  end
end
