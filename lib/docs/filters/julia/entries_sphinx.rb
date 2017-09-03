module Docs
  class Julia
    class EntriesSphinxFilter < Docs::EntriesFilter
      def get_name
        name = at_css('.document h1').content
        name.remove! "\u{00B6}"
        name
      end

      def get_type
        if slug.start_with?('manual')
          'Manual'
        else
          name
        end
      end

      def additional_entries
        return [] unless slug.start_with?('stdlib')
        entries = []

        css('.function dt[id]').each do |node|
          entries << [node['id'].remove('Base.') + '()', node['id']]
        end

        css('.data dt[id]').each do |node|
          entries << [node['id'].remove('Base.'), node['id']]
        end

        entries
      end
    end
  end
end
