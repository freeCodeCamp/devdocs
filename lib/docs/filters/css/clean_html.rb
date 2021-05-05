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
        css('.syntaxbox > .syntaxbox').each do |node|
          node.parent.before(node.parent.children).remove
        end

        # Remove "|" and "||" links in syntax box (e.g. animation, all, etc.)
        css('.syntaxbox', '.twopartsyntaxbox').css('a').each do |node|
          if node.content == '|' || node.content == '||'
            node.replace node.content
          end
        end

        css('img[style*="float"]').each do |node|
          node['style'] = node['style'] + ';float: none; display: block;'
        end
      end
    end
  end
end
