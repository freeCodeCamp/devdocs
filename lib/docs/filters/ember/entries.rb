module Docs
  class Ember
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if base_url.path.start_with?('/api')
          name = at_css('.api-header').content.split.first
          # Remove "Ember." prefix if the next character is uppercase
          name.sub! %r{\AEmber\.([A-Z])(?!EATURES)}, '\1'
          name == 'Handlebars.helpers' ? 'Handlebars Helpers' : name
        else
          name = at_css('article h1').content.remove('Edit Page').strip
          name = at_css('li.toc-level-0.selected > a').content if name == 'Introduction'
          name
        end
      end

      def get_type
        if base_url.path.start_with?('/api')
          if at_css('.api-header').content.include?('Module')
            'Modules'
          elsif name.start_with? 'DS'
            'Data'
          elsif name.start_with? 'RSVP'
            'RSVP'
          elsif name.start_with? 'Test'
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

        css('.item-entry:not(.inherited)').map do |node|
          heading = node.at_css('h3[data-id]')
          name = heading.content.strip

          if self.name == 'Handlebars Helpers'
            name << ' (handlebars helper)'
            next [name, heading['data-id']]
          end

          # Give their own type to "Ember.platform", "Ember.run", etc.
          if self.type != 'Data' && name.include?('.')
            type = "#{self.name}.#{name.split('.').first}"
          end

          # "." = class method, "#" = instance method
          separator = '#'
          separator = '.' if self.name == 'Ember' || self.name.split('.').last =~ /\A[a-z]/ || node.at_css('.static')
          name.prepend self.name + separator

          name << '()'     if node['class'].include? 'method'
          name << ' event' if node['class'].include? 'event'

          [name, heading['data-id'], type]
        end
      end
    end
  end
end
