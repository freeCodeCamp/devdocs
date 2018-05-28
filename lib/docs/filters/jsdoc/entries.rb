module Docs
  class Jsdoc
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.prepend 'JSDoc: ' if !name.include?('@') && !name.include?('JSDoc')
        name
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
            'Miscellaneous' # Only shown if a new category gets added in the upstream docs
        end
      end
    end
  end
end
