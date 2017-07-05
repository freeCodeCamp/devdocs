module Docs
  class Nim
    class EntriesFilter < Docs::EntriesFilter
      def get_type
        at_css('h1').content
      end

      def get_name
        at_css('h1').content
      end

      def additional_entries
        entries = []
        if get_name.start_with? 'Module '
          module_name = get_name[7..-1]
          css('div .section').map do |node|
            section_node = node.at_css('h1 a')
            if section_node != nil
              section_name = section_node.content.strip
              items_node = node.at_css('dl.item')
              if items_node != nil
                items_node.css('dt a').map do |item_node|
                  item_name = item_node['name']
                  if item_name.include? ','
                    item_name = item_name.sub(',', '(') + ')'
                  end
                  entries << [module_name + '.' + item_name, item_node.parent['id']]
                end
              end
            end
          end
        else
          css('h1', 'h2', 'h3').map do |node|
            id = node['id']
            name = node.content.strip
            if id != nil
              entries << [name, id]
            else
              a = node.at_css('a')
              if a != nil
                id = a['id']
                entries << [name, id]
              end
            end
          end
        end
        entries
      end
    end
  end
end
