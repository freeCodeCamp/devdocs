module Docs
  class Bootstrap
    class EntriesV4Filter < Docs::EntriesFilter
      def get_name
        name = at_css('.bd-content h1').content.strip
        name.remove! ' system'
        name == 'Overview' ? type : name
      end

      def get_type
        if subpath.start_with?('components')
          at_css('.bd-content h1').content.strip.prepend 'Components: '
        else
          at_css('.bd-toc-item.active > .bd-toc-link').content
        end
      end

      def additional_entries
        return [] if root_page? || subpath.start_with?('getting-started') || subpath.start_with?('migration')
        entries = []

        css('.bd-toc > ul > li > a', '.bd-toc a[href="#events"]', '.bd-toc a[href="#methods"]', '.bd-toc a[href="#triggers"]').each do |node|
          name = node.content
          next if name =~ /example/i || IGNORE_ENTRIES.include?(name)
          name.downcase!
          name.prepend "#{self.name}: "
          id = node['href'].remove('#')
          entries << [name, id]
        end

        css("#options + p + table tbody td:first-child").each do |node|
          name = node.content.strip
          id = node.parent['id'] = "#{name.parameterize}-option"
          name.prepend "#{self.name}: "
          name << ' (option)'
          entries << [name, id]
        end

        css("#methods + table tbody td:first-child, #methods ~ h4 code").each do |node|
          next unless name = node.content[/\('(\w+)'\)/, 1]
          unless id = node.parent['id']
            id = node.parent['id'] = "#{name.parameterize}-method"
          end
          name.prepend "#{self.name}: "
          name << ' (method)'
          entries << [name, id]
        end

        css("#events ~ table tbody td:first-child").each do |node|
          name = node.content.strip
          unless id = node.parent['id']
            id = node.parent['id'] = "#{name.parameterize}-event"
          end
          name.prepend "#{self.name}: "
          name << ' (event)'
          entries << [name, id]
        end

        entries
      end

      IGNORE_ENTRIES = %w(
        How\ it\ works
        Approach
        JavaScript\ behavior
        Usage
        Overview
        About
      )
    end
  end
end
