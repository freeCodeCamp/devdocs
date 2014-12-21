module Docs
  class Modernizr
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []

        css('h3[id]').each do |node|
          next unless name = node.content.strip[/\AModernizr\.\w+\(\)/]
          entries << [name, node['id'], 'Modernizr']
        end

        css('section[id]').each do |node|
          next unless heading = node.at_css('h3')
          next unless name = heading.content.strip[/\A(Modernizr\.)?\w+\(\)/]

          heading['id'] = node['id']
          node.remove_attribute('id')

          name.prepend('Modernizr.') unless name.start_with?('Modernizr')
          entries << [name, heading['id'], 'Modernizr']
        end

        css('h4[id^="features-"] + table').each do |table|
          type = table.previous_element.content.strip
          type << ' features' unless type.end_with?('features')

          table.css('tbody th[id]').each do |node|
            entries << [node.content, node['id'], type]
          end
        end

        entries
      end
    end
  end
end
