module Docs
  class Git
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        slug.sub '-', ' '
      end
    end
  end
end
