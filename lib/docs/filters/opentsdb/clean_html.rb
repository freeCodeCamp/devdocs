module Docs
  class Opentsdb 
    class CleanHtmlFilter < Filter
      def call
        # Reset the page scope to the body,
        # we needed the rest of the page for the entries filter.
        @doc = at_css(".documentwrapper > .bodywrapper > .body > .section")

        # Remove table borders 
        css('table').each { |table| table.delete 'border' }

        doc
      end
    end
  end
end
