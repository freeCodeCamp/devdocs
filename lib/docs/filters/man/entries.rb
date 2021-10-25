module Docs
  class Man
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if slug.match?(/[1-9].en$/)
          doc.document.title.split('—').first.strip
        else
          slug.split('/').first
        end
      end

      def get_type
        slug.split('/').first
      end
    end
  end
end
