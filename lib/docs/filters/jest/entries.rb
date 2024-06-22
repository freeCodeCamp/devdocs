module Docs
  class Jest
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        type = at_css('.menu__link--sublist.menu__link--active') # active sidebar element

        if type.nil?
          type = 'API Reference'
        else
          type = type.content
        end

        if type == 'Introduction'
          'Guides: Introduction'
        elsif type == 'API Reference'
          name
        else
          type
        end
      end

      def additional_entries
        return [] unless !root_page? && type == name # api page
        return [] if slug == 'environment-variables'
        return [] if slug == 'code-transformation'

        entries = []

        css('h3').each do |node|
          code = node.at_css('code')
          next if code.nil?

          name = code.content.strip
          name.sub! %r{\(.*\)}, '()'
          name.remove! %r{[\s=<].*}
          name.prepend 'jest ' if name.start_with?('--')
          name.prepend 'Config: ' if slug == 'configuration'
          id = node['id']

          entries << [name, id]
        end
        entries
      end
    end
  end
end
