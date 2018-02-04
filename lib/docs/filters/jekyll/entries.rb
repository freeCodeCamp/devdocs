module Docs
  class Jekyll
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        if slug.include?('continuous-integration')
          'Deployment'
        else
          nav_link = doc.document # document
            .at_css('aside li.current') # item in navbar

          if nav_link
            nav_link
              .parent # <ul> in navbar
              .previous_element # header before <ul>
              .content # category
          else
            'Miscellaneous'
          end
        end
      end

    end
  end
end
