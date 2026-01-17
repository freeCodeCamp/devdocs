module Docs
  class Powershell
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1')&.content || "PowerShell"
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
            'Module'
        end
      end
    end
  end
end
