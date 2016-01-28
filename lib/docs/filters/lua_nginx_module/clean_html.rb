module Docs
  class LuaNginxModule
    class CleanHtmlFilter < Filter
      def call
        type = nil
        doc.children.each do |node|
          if node.name == 'h1'
            section = node.content.strip
            type = section.in?(['Directives', 'Nginx API for Lua']) ? section : nil
          end

          if type == nil || (node.name == 'ul' && node.previous_element.name == 'h1') || node.content.strip == 'Back to TOC'
            node.remove()
          elsif node.name == 'h2'
            node["id"] = /^user-content-(.+)/.match(node.css('a.anchor').first["id"])[1]
          end
        end
        doc
      end
    end
  end
end
