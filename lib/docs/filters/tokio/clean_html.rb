module Docs
  class Tokio
    class CleanHtmlFilter < Filter
      def call
        css('.main-heading h1').each do |node|
          node.parent.replace(node)
        end

        doc.css(
          'a.doc-anchor',
          'a.anchor',
          'a.src',
          'button#copy-path',
          '.rustdoc-breadcrumbs',
          '.sub-heading'
        ).remove

        doc.css('pre.rust').each do |code|
          code['data-language'] = 'rust'
        end

        # Get rid of toggles hiding useful info.
        doc.css('details').each do |node|
          node.name = 'div'
        end
        doc.css('summary.hideme').remove

        doc
      end
    end
  end
end
