module Docs
  class Elisp
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        # remove numbers at the beginnig
        name = at_css('.chapter', '.section', '.subsection', '.subsubsection', '.appendix').content.slice(/[[:alpha:]]...*/)

        # remove 'Appendix' word
        name = name.sub(/Appendix.{2}/, '') if name.include?('Appendix')

        # remove 'E.' notation for appendixes
        if name.match?(/[[:upper:]]\./)
          # remove 'E.'
          name = name.sub(/[[:upper:]]\./, '')
          # remove all dots (.)
          name = name.gsub(/\./, '')
          # remove all numbers
          name = name.gsub(/[[:digit:]]/, '')
        end

        name
      end

      def get_type
        'Manual'
      end

      def additional_entries
        entries = []

        css('dl > dt').each do |node|
          if !(node.parent.attribute('compact'))
            entry_type = 'Builtin Functions' if node.content.include?('Function')
            entry_type = 'Builtin Macros' if node.content.include?('Macro')
            entry_type = 'Builtin Variables' if node.content.include?('Variable')
            entry_type = 'Builtin User Options' if node.content.include?('User Option')
            entry_type = 'Builtin Special Forms' if node.content.include?('Special Form')
            entry_type = 'Builtin Commands' if node.content.include?('Command')
            entry_type = 'Builtin Constants' if node.content.include?('Constant')

            entry_name = node.at_css('strong').content
            entry_path = slug + '#' + entry_name
            entries << [entry_name, entry_path.downcase, entry_type]
          end
        end

        entries
      end

    end
  end
end
