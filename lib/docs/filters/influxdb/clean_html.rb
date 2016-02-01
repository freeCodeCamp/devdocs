module Docs
  class Influxdb
    class CleanHtmlFilter < Filter
      def call
        doc = @doc.at_css('#page-content')

        # Re-position the page header
        header = at_css('.page--body h1')
        doc.children.first.add_next_sibling header

        # Remove the contribution
        at_css('.page--contribute').remove

        doc 
      end
    end
  end
end
