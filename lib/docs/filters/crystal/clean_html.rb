module Docs
  class Crystal
    class CleanHtmlFilter < Filter
      def call

        # Remove class attr from div and child nodes
        css("div").each do |node|
          node.xpath("//@class").remove
        end

        # Set id attributes on <h1> instead of an empty <a>
        css("h1").each do |node|
          node["id"] = node.at_css("a")["id"]
        end

        doc
      end
    end
  end
end
