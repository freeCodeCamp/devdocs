module Docs
  class Django
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css('.yui-g')

        css('.console-block').each do |node|
          node.css('input', 'label').remove
          node.css('section').each do |sec|
            sec.before(sec.children).remove
          end
          node.before(node.children).remove
        end

        doc
      end
    end
  end
end
