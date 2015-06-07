module Docs
  class Mongoose
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if slug == 'api'
          'Mongoose'
        else
          at_css('h1').content
        end
      end

      def get_type
        if slug == 'api'
          'Mongoose'
        else
          'Guides'
        end
      end

      def additional_entries
        return [] unless slug == 'api'
        entries = []

        css('h3[id]').each do |node|
          id = node['id']
          next if id == 'index_'

          id.sub!('%24', '$')
          node['id'] = id

          name = node.content.strip
          name.sub! %r{\(.+\)}, '()'
          next if name.include?(' ')

          type = name.split(/[#\.\(]/).first
          next if type.empty?
          entries << [name, id, type]
        end

        entries
      end
    end
  end
end
