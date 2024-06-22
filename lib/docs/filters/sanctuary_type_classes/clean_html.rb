module Docs
  class SanctuaryTypeClasses
    class CleanHtmlFilter < Filter
      def call
        # Make headers bigger by transforming them into a bigger variant
        css('h3').each { |node| node.name = 'h2' }
        css('h4').each { |node|
          node.name = 'h3'
        }

        # correct and unify link ids
        css('h3').each { |node|
          node.attributes["id"].value = node.text.split(' :: ')[0]
        }

        doc
      end
    end
  end
end
