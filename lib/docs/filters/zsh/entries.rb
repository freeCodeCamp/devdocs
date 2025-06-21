module Docs
  class Zsh
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        extract_header_text(at_css('h1.chapter').content)
      end

      def additional_entries
        entries = []

        css('h2.section').each do |node|
          type = get_type

          # Linkable anchor sits above <h2>.
          a = node.xpath('preceding-sibling::a').last
          header_text = extract_header_text(node.content)

          if type == 'Zsh Modules'
            module_name = header_text.match(/The (zsh\/.*) Module/)&.captures&.first
            header_text = module_name if module_name.present?
          end

          entries << [header_text, a['name'], type] if header_text != 'Description'
        end

        entries
      end

      def get_type
        extract_header_text(at_css('h1.chapter').content)
      end

      private

      # Extracts text from a string, dropping indices preceding it.
      def extract_header_text(str)
        str.match(/^[\d\.]* (.*)$/)&.captures&.first
      end
    end
  end
end
