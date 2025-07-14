module Docs
  class Tcllib
    class CleanHtmlFilter < Filter
      def call
        css("hr").remove()
        xpath("./div/text()").remove() # Navigation text content e.g. [ | | | ]
        css("div.markdown > a").remove() # Navigation links


        # Fix up ToC links
        css('a[name]').each do |node|
          node.parent['id'] = node['name']
          node.before(node.children).remove unless node['href']
        end

        # Relies on the above ToC fixup
        keywords = at_css('#keywords')
        if !keywords.nil?
          keywords.next_sibling.remove()
          keywords.remove()
          css('a[href="#keywords"]').remove()
        end

        # Downrank headings for styling
        css('h2').each do |node|
          node.name = 'h3'
        end
        css('h1').each do |node|
          node.name = 'h2'
        end

        css('pre').each do |node|
          node['data-language'] = 'tcl'
        end

        doc
      end
    end
  end
end
