module Docs

  class Nushell
    class FixLinksFilter < Filter
      def call
        css('header').remove
        css('aside').remove
        css('a').each do |node|
          if !(node["href"].starts_with?("https://") || node["href"].starts_with?("http://"))
            node["href"] = "#{node["href"]}#_"
          end
        end
        doc
      end
    end
  end

end
