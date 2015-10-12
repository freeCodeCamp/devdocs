module Docs
  class Modernizr
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []

        css('h3[id]').each do |node|
          next unless name = node.content.strip[/\AModernizr\..+/]
          entries << [name, node['id'], 'Modernizr']
        end

        css('h2[id="features"] + table td:nth-child(2) b').each do |node|
          node['id'] = node.content.parameterize
          node.content.split(',').each do |name|
            entries << [name, node['id'], 'Features']
          end
        end

        entries
      end
    end
  end
end
