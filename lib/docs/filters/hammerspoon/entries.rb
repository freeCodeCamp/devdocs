module Docs
  class Hammerspoon
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css("h1").content
      end

      def get_type
        slug.split("/").first
      end

      def additional_entries
        return [] if root_page?
        entries = []

        # add a base entry
        entries << [name, nil, name]

        css("section").each do |section|
          title_node = section.at_css("h5")
          if title_node.nil?
            next
          end
          entry_name = title_node.content.strip
          entry_id = section["id"]

          fn_type = section.at_css("a.dashAnchor").get_attribute("name")
          # this dashAnchor is the most consistent way to get the type of the entry
          if fn_type.start_with?("//apple_ref/cpp/Function")
            fn_type = "Function"
            entry_name << "()"
          elsif fn_type.start_with?("//apple_ref/cpp/Constructor/")
            fn_type = "Constructor"
            entry_name << "()"
          elsif fn_type.start_with?("//apple_ref/cpp/Method")
            fn_type = "Method"
            entry_name << "()"
          elsif fn_type.start_with?("//apple_ref/cpp/Class")
            fn_type = "Class"
          elsif fn_type.start_with?("//apple_ref/cpp/Constant")
            fn_type = "Constant"
          elsif fn_type.start_with?("//apple_ref/cpp/Variable")
            fn_type = "Variable"
          elsif fn_type.start_with?("//apple_ref/cpp/Deprecated")
            fn_type = "Deprecated"
          elsif fn_type.start_with?("//apple_ref/cpp/Field")
            fn_type = "Field"
          else
            fn_type = "Unknown"
          end

          # Create a new entry for each method/function
          if fn_type != "Unknown"
            entries << ["#{name}.#{entry_name}", entry_id, name]
          end

        end

        entries
      end

      def include_default_entry?
        # Decide when to include the default entry
        # Here we include it unless the page is a module overview or similar
        !subpath.end_with?("index.lp")
      end
    end
  end
end
