module Docs
  class Jsdoc
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end
      def get_type
        case slug
          when /^about-/
            'Getting Started'
          when /^plugins-/
            'Plugins'
          when /^howto-/
            'Examples'
          when /^tags-inline-/
            'Inline Tags'
          when /^tags-/
            'Tags'
          else
            'Other' # Only shown if a new category gets added in the upstream docs
        end
      end
    end
  end
end
