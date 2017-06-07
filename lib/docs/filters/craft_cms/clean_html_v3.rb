module Docs
  class CraftCms
    class CleanHtmlV3Filter < Filter
      def call
        
        # Add <a> for quick lookup
        css('header.h3 h3').each do |node|
          name = node.at_css('code').content.strip
          tag  = name.tr('()', '') + '-detail'
          node.at_css('code').inner_html = "<a id=" + tag + ">" + name + "</a>"
        end
        
        css('h2').each do |node|
          node.at_css('a')['id'] = node.at_css('a')['href'].tr('#', '')
        end
        
        doc
      end
    end
  end
end
