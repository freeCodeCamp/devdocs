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
      end


      def other
        # Re-create the header element
        at_css("#wiki").child.before("<h1>#{at_css("#wikititle").content}</h1>")

        @doc = at_css("#wiki")

        css('.contents', 'a.anchor', 'hr').remove

        css('pre').each do |node|
          node.content = node.content
        end
      end
    end
  end
end
