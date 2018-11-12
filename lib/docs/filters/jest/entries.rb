module Docs
  class Jest
    class EntriesFilter < Docusaurus::EntriesFilter
      def get_type
        type = super

        if type == 'Introduction'
          'Guides: Introduction'
        elsif type == 'API Reference'
          self.name
        else
          type
        end
      end

      def additional_entries
        return [] unless !root_page? && self.type == self.name # api page

        at_css('ul').css('li > a').map do |node|
          name = node.at_css('code').content.strip
          name.sub! %r{\(.*\)}, '()'
          name.remove! %r{[\s=<].*}
          name.prepend 'jest ' if name.start_with?('--')
          name.prepend 'Config: ' if slug == 'configuration'
          id = node['href'].remove('#')
          [name, id]
        end
      end
    end
  end
end
