module Docs
  class Nokogiri2
    class EntriesFilter < Docs::Rdoc::EntriesFilter
      def get_type
        type = name.dup
        type.remove! %r{#.+\z}
        type.split('::')[0..2].join('::')
      end
    end
  end
end
