module Docs
  class ReactNative
    class CleanHtmlFilter < Filter
      def call
        if root_page?
          css('#unsupported + div + center', '#unsupported + div', '#unsupported', '.toggler', 'center > img').remove
        end

        css('center > .button', 'p:contains("short survey")').remove

        doc
      end
    end
  end
end
