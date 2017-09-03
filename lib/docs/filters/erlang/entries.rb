module Docs
  class Erlang
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name << " (#{type.remove('Guide: ')})" if name == '1 Introduction'
        name.sub! %r{\A(\d+)}, '\1.'
        name
      end

      def get_type
        name = at_css('h1').content.strip

        if subpath.start_with?('lib/')
          type = subpath[/lib\/(.+?)[\-\/]/, 1]
          type << "/#{name}" if type == 'stdlib' && entry_nodes.length >= 10
          type
        elsif subpath.start_with?('doc/')
          type = subpath[/doc\/(.+?)\//, 1]
          type.capitalize!
          type.sub! '_', ' '
          type.sub! 'Oam', 'OAM'
          type.remove! ' Guide'
          type.prepend 'Guide: '
          type
        elsif subpath.start_with?('erts')
          type = 'ERTS'
          if name =~ /\A\d/
            type.prepend 'Guide: '
          elsif entry_nodes.length > 0
            type << "/#{name}"
          end
          type
        end
      end

      def include_default_entry?
        !at_css('.frontpage')
      end

      def additional_entries
        return [] unless include_default_entry?

        if subpath.start_with?('lib/')
          names = Set.new
          entry_nodes.each_with_object [] do |node, entries|
            id = node['name']
            name = id.remove %r{\-\d*\z}
            name << ' (type)' if name.sub!(/\Atype-/, '')
            name.remove! 'Module:'
            name.prepend "#{self.name}:"
            entries << [name, id] if names.add?(name)
          end
        elsif subpath.start_with?('doc/')
          []
        elsif subpath.start_with?('erts')
          return [] if type.start_with?('Guide')
          entry_nodes.map do |node|
            id = node['href'][/#(.+)/, 1]
            name = node.content.strip
            name.remove! 'Module:'
            name.prepend "#{self.name}:"
            [name, id]
          end
        end
      end

      def entry_nodes
        @entry_nodes ||= if subpath.start_with?('lib/')
          css('p + div.REFBODY').each_with_object [] do |node, result|
            result.concat(node.previous_element.css('a[name]').to_a)
          end
        elsif subpath.start_with?('erts')
          link = at_css(".flipMenu a[href='#{File.basename(subpath, '.html')}']")
          list = link.parent.parent
          list['class'] == 'flipMenu' ? [] : list.css('a').to_a.tap { |a| a.delete(link); }
        end
      end
    end
  end
end
