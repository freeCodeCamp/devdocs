module Docs
  class Backbone
    class EntriesFilter < Docs::EntriesFilter
      def additional_entries
        entries = []
        type = nil

        css('[id]').each do |node|
          # Module
          if node.name == 'h2'
            type = node.content.remove 'Backbone.'
            if type.capitalize! # sync, history
              entries << [node.content, node['id'], type]
            end
            next
          end

          # Built-in events
          if node['id'] == 'Events-catalog'
            node.next_element.css('li').each do |li|
              name = "#{li.at_css('b').content.delete('"').strip} event"
              id = name.parameterize
              li['id'] = id
              entries << [name, id, type] unless name == entries.last[0]
            end
            next
          end

          # Method
          name = node.at_css('.header').content.split.first

          # Underscore methods
          if name.start_with?('Underscore')
            node.at_css('~ ul').css('li').each do |li|
              name = [type.downcase, li.at_css('a').content.split.first].join('.')
              id = name.parameterize
              li['id'] = id
              entries << [name, id, type]
            end
            next
          end

          if %w(Events Sync).include?(type)
            name.prepend 'Backbone.'
          elsif type == 'History'
            name.prepend 'Backbone.history.'
          elsif name == 'extend'
            name.prepend "#{type}."
          elsif name.start_with? 'constructor'
            name = type
          elsif type != 'Utility'
            name.prepend "#{type.downcase}."
          end

          entries << [name, node['id'], type]
        end

        entries
      end
    end
  end
end
