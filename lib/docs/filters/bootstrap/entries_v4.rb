module Docs
  class Bootstrap
    class EntriesV4Filter < Docs::EntriesFilter
      def get_name
        name = at_css('.bd-content h1').content.strip
        name.remove! ' system'
        return type if name == 'Overview'
        name.prepend 'Utilities: ' if subpath.start_with?('utilities')
        name
      end

      def get_type
        if subpath.start_with?('components')
          at_css('.bd-content h1').content.strip.prepend 'Components: '
        else
          at_css('.bd-pageheader h1').content
        end
      end

      def additional_entries
        return [] if root_page? || subpath.start_with?('getting-started')
        entries = []

        css('#markdown-toc > li > a', '#markdown-toc > li li #markdown-toc-events').each do |node|
          name = node.content
          next if name =~ /example/i || IGNORE_ENTRIES.include?(name)
          name.downcase!
          name.prepend "#{self.name}: "
          id = node['href'].remove('#')
          entries << [name, id]
        end

        css("#options + p + div tbody td:first-child").each do |node|
          name = node.content.strip
          id = node.parent['id'] = "#{name.parameterize}-option"
          name.prepend "#{self.name}: "
          name << ' (option)'
          entries << [name, id]
        end

        css("#methods + table tbody td:first-child, #methods ~ h4 code").each do |node|
          next unless name = node.content[/\('(\w+)'\)/, 1]
          id = node.parent['id'] = "#{name.parameterize}-method"
          name.prepend "#{self.name}: "
          name << ' (method)'
          entries << [name, id]
        end

        entries
      end

      IGNORE_ENTRIES = %w(
        Contents
        How\ it\ works
        Approach
        JavaScript\ behavior
        Usage
        Basics
        Overview
      )
    end
  end
end
