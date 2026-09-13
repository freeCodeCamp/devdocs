module Docs
  class Elisp
    class EntriesFilter < Docs::EntriesFilter
      TYPES = {
        'Function' => 'Builtin Functions',
        'Predicate' => 'Builtin Functions',
        'Macro' => 'Builtin Macros',
        'Variable' => 'Builtin Variables',
        'User Option' => 'Builtin User Options',
        'Special Form' => 'Builtin Special Forms',
        'Command' => 'Builtin Commands',
        'Prefix Command' => 'Builtin Commands',
        'Constant' => 'Builtin Constants'
      }

      def get_name
        # the CleanHtmlFilter already removed the numbering from the headers
        at_css('.chapter', '.section', '.subsection', '.subsubsection', '.appendix').content
      end

      def get_type
        'Manual'
      end

      def additional_entries
        entries = []

        css('dl > dt').each do |node|
          name = node.at_css('.def-name')
          next unless name

          category = node.at_css('.category-def')
          entry_type = TYPES[category.content.strip.chomp(':')] if category
          # the CleanHtmlFilter turned the name into the id of the definition
          entries << [name.content, node['id'], entry_type]
        end

        entries
      end

    end
  end
end
