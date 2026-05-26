module Docs
  class Odin
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        title = context[:html_title].gsub(/ \| Odin Programming Language/, "")
        title
      end

      def get_type
        if subpath.start_with?('docs')
          "Documentation"
        elsif subpath.start_with?('spec')
          "Specifications"
        end
      end

      def additional_entries
        entries = []
        entries
      end
    end
  end
end

