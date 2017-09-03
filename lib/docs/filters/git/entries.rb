module Docs
  class Git
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if slug == 'user-manual'
          'User Manual'
        else
          slug.sub '-', ' '
        end
      end

      def get_type
        if link = at_css("#topics-dropdown a[href='#{slug}']")
          link.ancestors('ul').first.previous_element.content
        elsif slug == 'git' || slug.start_with?('git-')
          'Git'
        else
          'Miscellaneous'
        end
      end
    end
  end
end
