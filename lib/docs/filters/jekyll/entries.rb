module Docs
  class Jekyll
    class EntriesFilter < Docs::EntriesFilter
      # Information for which high-level category a page belongs to only exists
      # on the first level hierarchy. Beyond that, we have to use slug.
      TYPE_BY_DIR = {
        'installation' => 'Getting Started',
        'community' => 'Getting Started',

        'usage' => 'Build',
        'configuration' => 'Build',
        'rendering-process' => 'Build',

        'liquid' => 'Site Structure',

        'plugins' => 'Guides',
        'deployment' => 'Guides',

        'continuous-integration' => 'Deployment'
      }

      def get_name
        if slug.split('/').first == 'step-by-step'
          at_css('h2').content
        else
          at_css('h1').content
        end
      end

      def get_type
        if slug.split('/').first == 'step-by-step'
          'Tutorial'
        else
          nav_link = doc.document # document
            .at_css('aside li.current') # item in navbar

          if nav_link
            nav_link
              .parent # <ul> in navbar
              .previous_element # header before <ul>
              .content # category
          else
            if TYPE_BY_DIR.key?(slug.split('/').first)
              TYPE_BY_DIR[slug.split('/').first]
            else
              'Miscellaneous'
            end
          end
        end
      end

    end
  end
end
