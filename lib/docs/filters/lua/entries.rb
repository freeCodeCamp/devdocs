module Docs
  class Lua
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        type = nil

        doc.children.each_with_object [] do |node, entries|
          if node.name == 'h1'
            type = node.content.strip
            type.remove! %r{.+\u{2013}\s+}
            type.remove! 'The '
            type = 'API' if type == 'Application Program Interface'
          end

          next if type && type.include?('Incompatibilities')
          next if node.name == 'h2' && type.in?(%w(API Auxiliary\ Library Standard\ Libraries))

          if node.name == 'h2' || node.name == 'h3'
            name = node.content
            name.remove! %r{.+\u{2013}\s+}
            name.remove! %r{\[.+\]}
            name.gsub! %r{\s+\(.*\)}, '()'
            entries << [name, node['id'], type]
          end
        end
      end
    end
  end
end
