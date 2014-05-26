module Docs
  class Laravel
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if api_page?
          at_css('h1').content.strip.split('\\').last
        else
          at_css('h1').content.strip
        end
      end

      def get_type
        if api_page?
          type = at_css('h1').content.strip.remove('Illuminate\\').remove(/\\\w+?\z/)
          type.end_with?('Console') ? type.split('\\').first : type
        else
          'Guides'
        end
      end

      def additional_entries
        return [] unless api_page?

        css('h3[id^="method_"]').each_with_object [] do |node, entries|
          next if node.at_css('.location').content.start_with?('in')

          name = node['id'].remove('method_')
          name.prepend "#{self.name}::"
          name << '()'

          entries << [name, node['id']]
        end
      end

      def api_page?
        subpath.start_with?('/api')
      end
    end
  end
end
