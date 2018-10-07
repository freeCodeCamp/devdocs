module Docs
  class Python
    class CleanHtmlFilter < Filter
      def call
        @doc = at_css '.body'

        root_page? ? root : other

        doc
      end

      def root
        at_css('h1').content = 'Python'
      end

      def other
        css('h1').each do |node|
          node.content = node.content.sub(/\A[\d\.]+/) do |str|
            rgx = /\A#{str}/
            @levelRegexp = @levelRegexp ? Regexp.union(@levelRegexp, rgx) : rgx
            ''
          end
        end

        unless @levelRegexp.nil?
          css('h2', 'h3', 'h4').each do |node|
            node.inner_html = node.inner_html.remove @levelRegexp
          end
        end
      end
    end
  end
end
