module Docs
  class Lodash
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []

        css('.toc-container h2').each do |heading|
          type = heading.content.split.first

          heading.parent.css('a').each do |link|
            name = link.content
            name.remove! %r{\s.*}
            entries << [name, link['href'].remove('#'), type]
          end
        end

        entries
      end
    end
  end
end
