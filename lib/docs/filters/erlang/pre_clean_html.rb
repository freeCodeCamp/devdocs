module Docs
  class Erlang
    class PreCleanHtmlFilter < Filter
      def call
        css('.flipMenu li[title] > a').remove unless subpath.start_with?('erts') # perf

        doc
      end
    end
  end
end
