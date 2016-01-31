module Docs
  class Erlang
    class PreCleanHtmlFilter < Filter
      def call
        css('.flipMenu li[title] > a').remove
        doc
      end
    end
  end
end
