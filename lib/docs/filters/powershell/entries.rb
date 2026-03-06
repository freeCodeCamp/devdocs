module Docs
  class Powershell
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1')&.content.chop.chop || "" # remove the extra ' #'
      end

      def get_type
        case slug
          when /^docs-conceptual/
            'Scripting'
          when /^5\.1/
            '5.1'
          when /^7\.4/
            '7.4'
          when /^7\.5/
            '7.5'
          when /^7\.6/
            '7.6'
          else
            'Manual'
        end
      end
    end
  end
end
