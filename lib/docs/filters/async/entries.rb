module Docs
  class Async
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        type = nil
        entries = []

        css('.nav.methods li').each do |node|
          if node['class'] == 'toc-header'
            type = node.content
          else
            name = node.content
            id = node.at_css('a')['href'].remove('#')
            entries << [name, id, type]
          end
        end

        entries
      end
    end
  end
end
