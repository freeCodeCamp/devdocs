module Docs
  class Erlang
    class CleanHtmlFilter < Filter
      def call
        css('#leftnav').remove
        css('#content .innertube center:last-child').remove
        css('.function-name+br').remove
        css('#content .footer').remove
        doc
      end
    end
  end
end
