module Docs

  class Sanctuary
    class CleanHtmlFilter < Filter
      def call
        # Remove redundant section links from table of contents.
        doc.at("a[href='#section:api']").next_element.unlink()

        # Remove pilcrows.
        doc.css(".pilcrow").remove()

        # Insert Fink link in place of logo.
        doc.at("[id='section:sponsors'] ~ ul > li > p").prepend_child(
          doc.document.create_element("a", "Fink", {"href" => "https://www.fink.no/"})
        )

        # Convert code blocks to the correct structure for syntax highlighting.
        doc.css("code[class^='language-']").each { |node|
          node.parent.replace(
            doc.document.create_element(
              "pre",
              node.content,
              {"data-language" => node.attributes["class"].value.delete_prefix("language-")}
            )
          )
        }

        # Convert interactive examples to straightforward code blocks.
        doc.css(".examples").each { |node|
          node.replace(
            doc.document.create_element(
              "pre",
              node
                .css("input")
                .map { |node| "> " + node.attributes["value"].value }
                .zip(node.css(".output").map { |node| node.content })
                .map { |pair| pair.join("\n") }
                .join("\n\n"),
              {"data-language" => "javascript"}
            )
          )
        }

        # Remove example that requires interactivity.
        pre = doc.at("[id='section:overview'] ~ pre")
        p = pre.previous_element
        if p.content == "Try changing words to [] in the REPL below. Hit return to re-evaluate."
          p.unlink()
          pre.unlink()
        else
          raise "Failed to find interactive example within overview section"
        end

        doc
      end
    end
  end

end
