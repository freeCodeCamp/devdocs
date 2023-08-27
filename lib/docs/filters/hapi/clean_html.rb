module Docs

  class Hapi
    class CleanHtmlFilter < Filter
      def call

        # set ids
        css('h3 a:first-of-type, h4 a:first-of-type').each { |node|
          node.parent["id"] =  node["id"]
        }

        # set highlighting language
        css('code, pre').each { |node|
          node["data-language"] = 'javascript'
          node.classes << 'language-javascript'
        }

        doc
      end
    end
  end

end
