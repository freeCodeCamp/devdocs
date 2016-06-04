module Docs
  class Padrino
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1, h2').content
        name.remove! 'Class: '
        name.remove! 'Module: '
      end

      def get_type
        type = name.dup
        type.remove! %r{#.+\z}
        type.split('::')[0..2].join('::')
      end
    end
  end
end
