module Docs
  class Ember
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if base_url.path.start_with?('/api')
          name = at_css('h1').child.content.strip
          # Remove "Ember." prefix if the next character is uppercase
          name.sub! %r{\AEmber\.([A-Z])(?!EATURES)}, '\1'
          name << ' (methods)' if subpath.end_with?('/methods')
          name << ' (properties)' if subpath.end_with?('/properties')
          name << ' (events)' if subpath.end_with?('/events')
          name
        else
          name = at_css('article h1').content.remove('Edit Page').strip
          name = at_css('li.toc-level-0.selected > a').content if name == 'Introduction'
          name
        end
      end

      def get_type
        if base_url.path.start_with?('/api')
          name = self.name.remove(/ \(.*/)
          if name =~ /\A[a-z\-]+\z/
            'Modules'
          elsif name.start_with?('DS')
            'Data'
          elsif name.start_with?('RSVP')
            'RSVP'
          elsif name.start_with?('Test')
            'Test'
          elsif name.start_with?('Ember')
            name.split('.')[0..1].join('.')
          else
            name.split('.').first
          end
        else
          if node = at_css('li.toc-level-0.selected > a')
            "Guide: #{node.content.strip}"
          else
            'Guide'
          end
        end
      end

      def additional_entries
        return [] unless base_url.path.start_with?('/api')

        css('section').each_with_object [] do |node, entries|
          next unless heading = node.at_css('h3[data-anchor]')
          next if node.at_css('.github-link').content.include?('Inherited')
          name = heading.at_css('span').content.strip

          # Give their own type to "Ember.platform", "Ember.run", etc.
          if self.type != 'Data' && name.include?('.')
            type = "#{self.name.remove(/ \(.*/)}.#{name.split('.').first}"
          end

          name.prepend "#{self.name.remove(/ \(.*/)}."
          name << '()' if node['class'].include?('method')
          name << ' (event)' if node['class'].include?('event')

          entries << [name, heading['data-anchor'], type]
        end
      end
    end
  end
end
