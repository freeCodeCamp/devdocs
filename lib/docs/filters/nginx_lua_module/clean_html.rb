module Docs
  class NginxLuaModule
    class CleanHtmlFilter < Filter
      def call
        css('a[href="#table-of-contents"]', 'a:contains("Back to TOC")').remove

        css('h1, h2, h3').each do |node|
          node.name = node.name.sub(/\d/) { |i| i.to_i + 1 }
        end

        css('a > img').each do |node|
          node.parent.before(node.parent.children).remove
        end

        doc
      end
    end
  end
end
