module Docs
  class Codeigniter
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content.strip
      end

      def get_type
        type = slug.split('/').first.capitalize

        if type.in? %w(Tutorial Installation Overview General)
          type.prepend 'User guide: '
        elsif type.in? %w(Libraries Helpers)
          type = name.remove %r{\ (?:Helper|Class|Classes|Library|Driver)\z}
        end

        type
      end

      def additional_entries
        entries = []

        css('.class').each do |node|
          class_name = node.at_css('dt > .descname').content
          class_id = node.at_css('dt[id]')['id']
          entries << [class_name, class_id]

          node.css('.method').each do |n|
            name = n.at_css('.descname').content
            name = "#{class_name}::#{name}()"
            id = node.at_css('dt[id]')['id']
            entries << [name, id]
          end
        end

        css('.function').each do |node|
          name = "#{node.at_css('.descname').content}()"
          id = node.at_css('dt[id]')['id']
          type = self.type.start_with?('User guide') ? 'Functions' : self.type
          entries << [name, id, type]
        end

        entries
      end
    end
  end
end
