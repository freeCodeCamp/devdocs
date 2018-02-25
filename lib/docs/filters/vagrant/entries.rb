module Docs
  class Vagrant
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if slug.start_with?('push/')
          name = at_css('#inner h2').try(:content)
        elsif slug.start_with?('cli/')
          name = at_css('#inner h1 + p > strong > code').try(:content).try(:[], /\s*vagrant\s+[\w\-]+/)
        end

        name ||= at_css('#inner h1').content
        name.remove! "» "
        name
      end

      def get_type
        type = at_css('.docs-sidenav > li.active > a').content
        node = at_css('.docs-sidenav > li.active > ul > li.active > a + ul')
        type << ": #{node.previous_element.content}" if node
        type
      end

      def additional_entries
        case at_css('h1 + p > strong > code').try(:content)
        when /config\./
          h2 = nil
          css('#inner > *').each_with_object [] do |node, entries|
            next if node.name == 'pre'
            if node.name == 'h2'
              h2 = node['id']
            elsif h2 == 'available-settings' && (code = node.at_css('code')) && (name = code.content) && name.start_with?('config.')
              name.sub! %r{\s+=.*}, '='
              id = code.parent['id'] = name.parameterize
              entries << [name, id, 'Config']
            end
          end
        else
          []
        end
      end
    end
  end
end
