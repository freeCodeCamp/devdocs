module Docs
  class Css
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        # Remove "CSS3 Tutorials" and everything after
        css('#CSS3_Tutorials ~ *', '#CSS3_Tutorials').remove
      end

      def other
        # Remove "|" and "||" links in syntax box (e.g. animation, all, etc.)
        css('.syntaxbox', '.twopartsyntaxbox').css('a').each do |node|
          if node.content == '|' || node.content == '||'
            node.replace node.content
          end
        end
      end
    end
  end
end
