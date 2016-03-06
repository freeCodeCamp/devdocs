module Docs
  class Haxe
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = slug.dup
        name.gsub!('/', '.')
        name.remove! "#{slug.split('/').first}\."
        name
      end

      def get_type
        path = *current_url.path.split('/')[1..-1]

        return 'std' if path.length == 1

        path = path.take_while { |str| str =~ /\A[a-z]/}
        path[0..2].join('.')
      end

      def additional_entries
        return [] if root_page? || self.name.start_with?('_') || self.name.include?('Error')

        css('h3[id]').each_with_object [] do |node, entries|
          id = node['id']
          next if id == 'new'
          name = "#{self.name}.#{id}"
          name << '()' if node.content.include?('(')
          entries << [name, id]
        end
      end

      def include_default_entry?
        subpath !~ /index\.html\z/
      end
    end
  end
end
