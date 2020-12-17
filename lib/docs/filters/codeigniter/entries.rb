module Docs
  class Codeigniter
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove! "\u{00B6}"
        name
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

        css('.class', '.interface').each do |node|
          class_name = node.at_css('dt > .descname').content.split('\\').last
          class_id = node.at_css('dt[id]')['id']
          entries << [class_name, class_id]

          node.css('.method', '.staticmethod').each do |n|
            next unless n.at_css('dt[id]')
            name = n.at_css('.descname').content
            name = "#{class_name}::#{name}()"
            id = n.at_css('dt[id]')['id']
            entries << [name, id]
          end
        end

        css('.function').each do |node|
          name = "#{node.at_css('.descname').content}()"
          id = node.at_css('dt[id]')['id']
          type = self.type.start_with?('User guide') ? 'Functions' : self.type
          entries << [name, id, type]
        end

        css('.const').each do |node|
          name = node.at_css('.descname').content
          id = node.at_css('dt[id]')['id']
          type = self.type.start_with?('User guide') ? 'Global Constants' : self.type
          entries << [name, id, type]
        end

        entries
      end
    end
  end
end
