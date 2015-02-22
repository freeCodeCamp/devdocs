module Docs
  class Minitest
    class EntriesFilter < Docs::Rdoc::EntriesFilter
      def get_type
        type = name.dup
        type.remove! %r{#.+\z}
        type.split('::')[0..1].join('::')
      end
    end
  end
end
