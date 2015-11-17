module Docs
  class Dojo
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        list_of_names = name.split(/\/|\./)
        list_of_names.pop
        list_of_names.join("/")
      end
    end
  end
end