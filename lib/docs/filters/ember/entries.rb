module Docs
  class Ember
    class EntriesFilter < Docs::EntriesFilter
      def include_default_entry?
        name != 'Handlebars Helpers'
      end

      def get_name
        name = at_css('.api-header').content.split.first
        # Remove "Ember." prefix if the next character is uppercase
        name.sub! %r{\AEmber\.([A-Z])}, '\1'
        name == 'Handlebars.helpers' ? 'Handlebars Helpers' : name
      end

      def get_type
        # Group modules together
        if at_css('.api-header').content.include?('Module')
          'Modules'
        # Group "Ember Data" together
        elsif name.start_with? 'DS'
          'Data'
        else
          name
        end
      end

      def additional_entries
        css('.item-entry').map do |node|
          heading = node.at_css('h2')
          name = heading.content.strip

          if self.name == 'Handlebars Helpers'
            name << ' (handlebars helper)'
            next [name, heading['id']]
          end

          # Give their own type to "Ember.platform", "Ember.run", etc.
          if self.type != 'Data' && name.include?('.')
            type = "#{self.name}.#{name.split('.').first}"
          end

          # "." = class method, "#" = instance method
          separator = '#'
          separator = '.' if self.name == 'Ember' || self.name.split('.').last =~ /\A[a-z]/ || node.at_css('.static')

          name.prepend self.name + separator

          # Fix bug in DS.Adapter / "{Array} ids" and "{DS.Model} record"
          name.sub! %r[\{.+\}\s*], ''

          name << '()'     if node['class'].include? 'method'
          name << ' event' if node['class'].include? 'event'

          [name, heading['id'], type]
        end
      end
    end
  end
end
