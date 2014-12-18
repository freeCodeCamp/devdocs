module Docs
  class Selenium
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []

        types = ['actions', 'accessors']

        types.each do |type|
          node = doc.css("a[name='#{type}'] + h2 + dl")
          node.css('strong > a').each do |node|
            name = node['name']
            id = name.downcase
            entries << [name, id, type]
          end
        end
        entries
      end
    end
  end
end
