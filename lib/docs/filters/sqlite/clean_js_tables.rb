module Docs
  class Sqlite
    class CleanJsTablesFilter < Filter
      def call
        css('table[id]:empty + script').each do |node|
          json_list = JSON.parse(node.inner_html[/\[.+?\]/m])
          list = '<ul>'
          json_list.each do |item|
            list << '<li>'

            unless item['u'].blank? || item['s'] == 2
              list << %(<a href="#{item['u']}">)
              link = true
            end

            if item['s'] == 2 || item['s'] == 3
              list << "<s>#{item['x']}</s>"
            else
              list << item['x']
            end

            list << '</a>' if link

            if item['s'] == 1
              list << ' <small><i>(exp)</i></small>'
            elsif item['s'] == 3
              list << '&sup1;'
            elsif item['s'] == 4
              list << '&sup2;'
            elsif item['s'] == 5
              list << '&sup3;'
            end
          end
          list << '</ul>'
          node.previous_element.replace(list)
        end

        doc
      end
    end
  end
end
