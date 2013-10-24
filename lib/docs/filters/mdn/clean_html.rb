module Docs
  class Mdn
    class CleanHtmlFilter < Filter
      REMOVE_NODES = [
        '#Summary',          # "Summary" heading
        '.htab',             # "Browser compatibility" tabs
        '.breadcrumbs',      # (e.g. CSS/animation)
        '.Quick_links',      # (e.g. CSS/animation)
        '.HTMLElmNav',       # (e.g. HTML/a)
        '.htmlMinVerHeader', # (e.g. HTML/article)
        '.geckoVersionNote', # (e.g. HTML/li)
        '.todo',
        '.draftHeader']

      def call
        css(*REMOVE_NODES).remove

        css('td.header').each do |node|
          node.name = 'th'
        end

        doc
      end
    end
  end
end
