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
        return 'Guides' unless api_page?
        type = slug.remove('api/5.0/').remove('Illuminate/').remove(/\/\w+?\z/).gsub('/', '\\')

        if type.end_with?('Console')
          type.split('\\').first
        elsif type.start_with?('Contracts')
          'Contracts'
        else
          type
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
        subpath != '/api/5.0/classes.html'
      end
    end
  end
end
