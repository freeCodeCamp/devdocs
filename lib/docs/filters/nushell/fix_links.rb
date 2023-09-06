module Docs

  class Nushell
    class FixLinksFilter < Filter
      def call
        css('a').each do |node|
          node["href"] = "#{node["href"]}#_"
        end
        doc
      end
    end
  end

end
