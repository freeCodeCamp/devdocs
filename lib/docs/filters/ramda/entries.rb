module Docs
  class Ramda
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        css('ul.toc li').map do |item|
          name = item['data-name']
          category = item['data-category']

          ['R.' + name, name, category]
        end
      end
    end
  end
end
