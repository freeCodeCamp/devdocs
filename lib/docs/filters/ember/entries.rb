module Docs
  class Ember
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        if base_url.host.start_with?('api')
          name.gsub!('Package', '')
          name.gsub!('Class', '')
          name.strip!
          name << ' (methods)' if subpath.end_with?('/methods')
          name << ' (properties)' if subpath.end_with?('/properties')
          name << ' (events)' if subpath.end_with?('/events')
        end
        name
      end

      def get_type
        if base_url.host.start_with?('api')
          name = self.name.remove(/ \(.*/)
          if name == 'Function'
            '3. Functions'
          elsif at_css('h1').content.start_with?('Package')
            '2. Packages'
          else
            name = name.remove(' (methods)').remove(' (properties)').remove(' (events)')
            # Reference gets sorted to the top by default, need to have it with other classes so add a zero width space
            name == 'Reference' ? 'Reference​' : name
          end
        else
          '1. Guide'
        end
      end

      def include_default_entry?
        return false if name == 'Function' # these should be included in the corresponding Package page
 
        super
      end

      def additional_entries
        return [] unless base_url.host.start_with?('api')

        css('section').each_with_object [] do |node, entries|
          next unless heading = node.at_css('> h3[data-anchor]')

          name = heading.at_css('span').content.strip

          next if name.start_with?('_') # exclude private methods/properties

          name.prepend "#{self.name.remove(/ \(.*/)}." unless self.name == 'Function'
          name << '()' if node['class'].include?('method')
          name << ' (event)' if node['class'].include?('event')

          entries << [name, heading['data-anchor'], type]
        end
      end
    end
  end
end
