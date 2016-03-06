module Docs
  class Tensorflow
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove! 'class '
        name.remove! 'struct '
        name
      end

      def get_type
        type = name.dup
        type.remove! %r{\ \(.*\)}
        type.remove! 'tensorflow::'
        type
      end

      def additional_entries
        css('h2 code', 'h3 code', 'h4 code', 'h5 code').map do |node|
          name = node.content
          name.sub! %r{\(.*}, '()'
          name = name.split(' ').last
          [name, node.parent['id']]
        end
      end
    end
  end
end
