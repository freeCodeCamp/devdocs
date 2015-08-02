module Docs
  class Q
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entry = type = nil

        css('h3, h4, em:contains("Alias")').each_with_object [] do |node, entries|
          case node.name
          when 'h3'
            type = node.content.strip
            type.remove! %r{\(.+\)}
            type.remove! ' Methods'
            type.remove! ' API'
            entries << [type, node['id'], type] if type == 'Q.defer()'
          when 'h4'
            name = node.content.strip
            name.sub! %r{\(.*?\).*}, '()'
            id = node['id'] = name.parameterize
            entry = [name, id, type]
            entries << entry
          when 'em'
            name = node.parent.at_css('code').content
            name << '()' if entry[0].end_with?('()')
            dup = entry.dup
            dup[0] = name
            entries << dup
          end
        end
      end
    end
  end
end
