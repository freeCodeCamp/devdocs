module Docs
  class Sass
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        at_css('#main-content > h1').content
      end

      def get_type

        case slug
        when /syntax/
          'Syntax'
        when /style/
          'Style rules'
        when /at/
          'At-Rules'
        when /values/
          'Values'
        when /operators/
          'Operators'
        when /cli/
          'Command line'
        when /modules/
          'Modules'
        else
          'Misc'
        end

      end

      def additional_entries
        entries = []

        signatureElement = css('.signature')

        if signatureElement

          signatureElement.each do |node|

            entry_name = node.content

            if entry_name.match(/\(/)
              entry_name = entry_name.scan(/.+\(/)[0].chop
            end

            if entry_name.include?('$pi')
              entries << [entry_name, 'pi', 'Variable']
            elsif entry_name.include?('$e')
              entries << [entry_name, 'e', 'Variable']
            else
              entries << [entry_name, entry_name, 'Functions']
            end

          end

        end

        entries

      end

    end
  end
end
