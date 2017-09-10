module Docs
  class Laravel
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if api_page?
          name = at_css('h1').content.strip.remove('Illuminate\\')
          name << " (#{type})" unless name.start_with?(self.type)
          name
        else
          at_css('h1').content
        end
      end

      def get_type
        unless api_page?
          link = at_css(".sidebar li a[href='#{result[:path].split('/').last}']")
          heading = link.ancestors('li').last.at_css('> h2')
          return heading ? "Guides: #{heading.content.strip}" : 'Guides'
        end

        type = slug.remove(%r{api/\d.\d/}).remove('Illuminate/').remove(/\/\w+?\z/).gsub('/', '\\')

        if type.end_with?('Console')
          type.split('\\').first
        elsif type.start_with?('Contracts')
          'Contracts'
        elsif type.start_with?('Database')
          type.split('\\')[0..2].join('\\')
        else
          type.split('\\')[0..1].join('\\')
        end
      end

      def additional_entries
        return [] if root_page? || !api_page?
        base_name = self.name.remove(/\(.+\)/).strip

        css('h3[id^="method_"]').each_with_object [] do |node, entries|
          next if node.at_css('.location').content.start_with?('in')

          name = node['id'].remove('method_')
          name.prepend "#{base_name}::"
          name << '()'

          entries << [name, node['id']]
        end
      end

      def api_page?
        subpath.start_with?('/api')
      end

      def include_default_entry?
        !subpath.end_with?('classes.html')
      end
    end
  end
end
