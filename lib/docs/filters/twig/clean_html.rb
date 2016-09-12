module Docs
  class Twig
    class CleanHtmlFilter < Filter
      def call

        css('.infobar', '.admonition-note', 'ul.pages', '.offline-docs').remove

        doc
      end
    end
  end
end
