def repeat(n, s)
  Array.new(n, s).join("")
end

def _(n)
  repeat(n, " ")
end

module Docs

  class Sanctuary
    class CleanHtmlFilter < Filter
      def call
        # Remove header containing GitHub, Gitter, and Stack Overflow links.
        doc.at("#css-header").unlink()

        # Remove redundant section links from table of contents.
        doc.at("a[href='#section:api']").next_element.unlink()

        # Swap headings and accompanying pilcrows to aid positioning via CSS.
        doc.css(".pilcrow").each { |node| node.next_element.after(node) }

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
                .zip(node.css(".output").map { |node|
                  if node.content.start_with?("! Invalid value")
                    # XXX: Reinstate newlines and consecutive spaces.
                    content = node.content.dup()
                    content[ 15] = "\n\n"
                    content[ 68] = "\n" + _("add :: FiniteNumber -> ".size)
                    content[104] = "\n" + _("add :: FiniteNumber -> ".size + ("FiniteNumber".size - 1) / 2)
                    content[134] = "\n\n"
                    content[138] = _(2)
                    content[155] = "\n\n"
                    content[215] = "\n\n"
                    content[337] = "\n"
                    content
                  else
                    node.content
                  end
                })
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
