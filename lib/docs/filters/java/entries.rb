module Docs
  class Java
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if name = at_css('.typeNameLabel')
          name = name.content.strip
        else
          name = at_css('.header > .title').content.strip
        end
        name
      end

      def get_type
        if subTitle = at_css('.header > .subTitle:last-of-type')
          type = subTitle.content.strip
        else
          type = at_css('.header > .title').content.strip
          type.remove! 'Package '
        end
        type
      end

      def additional_entries
        entries = []
        entry_names = []

        # Map empty <a name> to id of next element
        css('.memberNameLink a').each do |node|
          entry_name = node.parent.parent.content.strip

          # include newlines in search
          entry_name.sub! %r{\([\w\W]*?\)}, '()'
          id = node['href']
          id.remove! %r{(.*#)}
          # Only add first found entry with unique name,
          # i.e. overloaded methods are skipped in index
          if id
            unless entry_names.include? entry_name
              entries << [name+'.'+entry_name, id]
              entry_names << entry_name
            end
          end
        end
        entries
      end
    end
  end
end