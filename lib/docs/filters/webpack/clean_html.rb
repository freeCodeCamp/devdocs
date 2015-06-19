module Docs
  class Webpack 
    class CleanHtmlFilter < Filter
      def call
        root_page? ? root : other
        doc
      end

      def root
        @doc = at_css(".container > .row > .col-md-9")

        # Remove all introdcution before the hr,
        # The introduction about the documentation site which isn't relevant
        # in devdocs.
        hr_index = doc.children.find_index { |node| node.name == "hr" }
        doc.children[0..hr_index].each(&:remove)

        # Add a page header :)
        page_header_node = Nokogiri::XML::Node.new "h1", @doc
        page_header_node.content = "Webpack"
        @doc.children.first.add_previous_sibling page_header_node
      end


      def other
        # Re-create the header element
        page_header = at_css("#wikititle").content.upcase
        page_header_node = Nokogiri::XML::Node.new "h1", @doc
        page_header_node.content = page_header

        # Change the scope of the page
        @doc = at_css("#wiki")

        # Add the page header
        @doc.children.first.add_previous_sibling page_header_node

        # Remove the sidebar links in each page
        css(".contents").remove

        # Remove all anchors
        css("a.anchor").remove

      end
    end
  end
end
