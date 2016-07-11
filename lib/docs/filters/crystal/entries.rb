module Docs
  class Crystal
    class EntriesFilter < Docs::EntriesFilter

      # Set the name to h1 content
      def get_name
        node = at_css("h1")
        node.content.strip
      end

      # Crystal types from url slug
      def get_type
        slug["blob/master/"] = ""
        object, method = *slug.split("/")
        object = object.capitalize
        method ? object : "Index"
      end

    end
  end
end
