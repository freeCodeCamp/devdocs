module Docs
    class Opengl
      class CleanHtmlFilter < Filter
        def call
          # Rmeove table from function definitions
          css('.funcprototype-table').each do |node|
            node.css('td').each do |data|
              data.replace(data.children)
            end
            node.css('tr').each do |row|
              row.replace(row.children)
            end
            node.wrap('<div>')
            node.parent['id'] = node.css('.fsfunc').text
            node.replace(node.children)
          end

          doc
        end
      end
    end
  end
