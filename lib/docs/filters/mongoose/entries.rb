module Docs
  class Mongoose
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        if slug.start_with? 'api'
          for heading in css('h3[id]')
            type = get_type_from heading
            return type if type
          end
        end
        'Guides'
      end

      def get_type_from node
        name = node.content.strip
        type = name.split(/[#\.\(]/).first
        if type.empty? || name.include?(' ')
          nil
        else
          type
        end
      end

      def additional_entries
        entries = []

        css('h3[id]').each do |node|
          id = node['id']
          next if id == 'index_'

          id.sub!('%24', '$')
          node['id'] = id

          name = node.content.strip
          name.sub! %r{\(.+\)}, '()'
          next if name.include?(' ')

          type = get_type_from node
          next if type.nil?
          entries << [name, id, type]
        end

        entries
      end
    end
  end
end
