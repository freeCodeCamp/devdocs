module Docs
  class Tensorflow
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.remove! 'class '
        name.remove! 'struct '
        name.remove! %r{\.\z}
        name.sub! 'tf.contrib', 'contrib' unless version == 'Guide'
        name
      end

      def get_type
        if version == 'Guide'
          type = subpath.start_with?('tutorials') ? 'Tutorials' : 'How-Tos'

          if node = at_css('.devsite-nav-item.devsite-nav-active')
            node = node.previous_element until !node || node['class'].include?('devsite-nav-item-heading')
            type << ": #{node.content}" if node
          end

          type
        elsif version == 'C++'
          name.remove 'tensorflow::'
        else
          node = at_css('.devsite-nav-item.devsite-nav-active')
          node = node.ancestors('.devsite-nav-item').first.at_css('.devsite-nav-title')
          type = node.content
          type.remove! %r{\.\z}
          type.prepend 'Contrib: ' if type.sub!(' (contrib)', '')
          type
        end
      end

      def additional_entries
        return [] if version == 'Guide'

        if version == 'C++'
          names = Set.new
          css('table.constructors td:first-child code a:first-child',
              'table.methods      td:first-child code a:first-child',
              'table.properties   td:first-child code a:first-child').each_with_object [] do |node, entries|
            name = node.content
            name.prepend "#{self.name}::"
            name << '()' unless node.ancestors('.properties').present?
            next unless names.add?(name)
            id = node['href'].remove('#')
            entries << [name, id]
          end
        else
          css('h2 code', 'h3 code', 'h4 code', 'h5 code').each_with_object [] do |node, entries|
            name = node.content
            name.sub! %r{\(.*}, '()'
            next if name.include?(' || ')
            name = name.split(' ').last
            entries << [name, node.parent['id']]
          end
        end
      end
    end
  end
end
