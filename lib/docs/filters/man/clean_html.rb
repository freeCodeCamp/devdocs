module Docs
  class Man
    class CleanHtmlFilter < Filter
      def call
        css('.anchor', '.panels', '.paneljump', 'table.head').remove
        doc
      end
    end
  end
end
