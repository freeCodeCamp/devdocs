module Docs
  class Fastapi
    class EntriesFilter < Docs::EntriesFilter

      def sanitized_path
        path.gsub(/index$/, "")
      end

      def path_parts
        sanitized_path.split("/")
      end

      def get_name
        at_css('h1').content
      end

      def get_name_other
        header = at_css('h1')
        if header
          header.content
        else
          path_parts.last.titleize
        end
      end

      def get_type
        if path_parts.length <= 1
          data = at_css('h1').content
        else
          data = path_parts[0...path_parts.length-1].join(": ").titleize + ": " + at_css('h1').content
        end

        data
      end

      def path_count
        path_parts.length
      end

      def additional_entries
        entries = []
        type = get_type

        css('h2').each do |node|
          name = node.content
          id = path + "#" + node['id']
          entries << [name, id, type]
        end

        entries
      end

    end
  end
end
