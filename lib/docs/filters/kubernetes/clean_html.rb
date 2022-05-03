module Docs
  class Kubernetes
    class CleanHtmlFilter < Filter

      def call

        # remove the API Operations section from the docs
        # by removing the h2 of id=Opetations
        # and all the preceding elements
        css('#Operations ~ *').remove
        css('#Operations').remove
        # remove horizontal rules
        css('hr').remove
        # remove footer (1.20)
        css('.pre-footer').remove

        doc 
      end

    end
  end
end
