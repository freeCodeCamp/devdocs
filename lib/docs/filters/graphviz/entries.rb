module Docs
  class Graphviz
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        name = at_css('h1').content.strip
      end

      def get_type
        breadcrumbs = css('nav ol.breadcrumb li.breadcrumb-item')
        category = breadcrumbs[1]&.content&.strip

        # These categories have several sub-pages.
        return category if [
          'Attribute Types',
          'Attributes',
          'Command Line',
          'Layout Engines',
          'Output Formats',
        ].include?(category)

        # Several categories have only one page each. Let's group them together.
        return 'Documentation'
      end

    end
  end
end
