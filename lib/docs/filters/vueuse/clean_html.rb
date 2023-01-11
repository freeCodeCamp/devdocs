module Docs
  class Vueuse
    class CleanHtmlFilter < Filter
      def call
        css('#demo, #contributors ~ div, #contributors, #changelog ~ div, #changelog').remove
        css('span.lang').remove
        css('pre.vp-code-dark').remove

        css('.grid').each do |table|
          table.name = 'table'
          tr = nil
          table.css('> div').each do |td|
            if td['opacity']
              table.add_child('<tr>')
              tr = table.last_element_child
              td.name = 'th'
              td.remove_attribute('opacity')
              tr.add_child(td.remove)
            else
              td.name = 'td'
              tr.add_child(td.remove)
            end
          end
        end

        doc
      end
    end
  end
end
