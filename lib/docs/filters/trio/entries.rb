module Docs
  class Trio
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').text[0...-1]
      end

      def get_type
        at_css('h1').text[0...-1]
      end

      def additional_entries
        css('.descname').each_with_object [] do |node, entries|
          name = node.text
          if node.previous.classes.include? 'descclassname'
            name = node.previous.text + name
          end
          name.strip!

          dl = node.parent.parent

          if dl.classes.include?('attribute') \
              or dl.classes.include?('method') \
              or dl.classes.include?('data')
            parent = dl.parent.previous_element
            cls = ''

            if n = parent.at_css('.descclassname')
              cls += n.text
            end

            if n = parent.at_css('.descname')
              if n.text == "The nursery interface"
                cls += "Nursery."
              else
                cls += n.text + '.'
              end
            end

            name = cls + name
          end

          entries << [name, node.parent['id']]
        end
      end
    end
  end
end
