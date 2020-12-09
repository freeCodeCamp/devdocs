module Docs
  class Bash
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        name = at_css('h1','h2', 'h3', 'h4').content.gsub(/(\d+\.?)+/, '')

        # remove 'E.' notation for appendixes
        if name.match?(/[[:upper:]]\./)
          # remove 'E.'
          name.sub!(/[[:upper:]]\./, '')
          # remove all dots (.)
          name.gsub!(/\./, '')
          # remove all numbers
          name.gsub!(/[[:digit:]]/, '')
        end

        name.strip

      end

      def get_type
        return 'Manual: Appendices' if name.start_with?('Appendix')
        return 'Manual: Indexes' if at_css('a[rel=up]').content.include?("Index")
        "Manual"
      end

      def additional_entries
        entry_type = {
          "Function Index" => "Functions",
          "Index of Shell Builtin Commands" => "Builtin Commands",
          "Index of Shell Reserved Words" => "Reserved Words",
          "Parameter and Variable Index" => "Parameters and Variables"
        }[name]

        # Only extract additional entries from certain index pages
        return [] if entry_type.nil?

        entries = []

        css('table[class^=index-] td[valign=top] > a').each_slice(2) do |entry_node, section_node|
          entry_name = entry_node.content

          page = section_node['href'].split('#')[0]
          hash = entry_name

          # The Special Parameters page has multiple additional entries which should link to the same paragraph
          # Example: the documentation for "$!" is equal to the documentation for "!"
          if page == 'special-parameters'
            if hash.size > 1 && hash[0] == '$'
              hash = hash[1..-1]
            end
          end

          # Construct path to the page which the index links to
          entry_path = page + '#' + hash

          entries << [entry_name, entry_path, entry_type]
        end

        entries
      end

    end
  end
end
