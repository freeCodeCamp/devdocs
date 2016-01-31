module Docs
  class Erlang
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.prepend 'Guide: ' if doc.inner_html.include?('<strong>User\'s Guide</strong>')
        name
      end

      def get_type
        type = subpath[/lib\/(.+?)[\-\/]/, 1]
        type << "/#{name}" if type == 'stdlib' && entry_nodes.length >= 10
        type
      end

      def include_default_entry?
        !at_css('.frontpage')
      end

      def additional_entries
        entry_nodes.map do |node|
          id = node['name']
          name = id.gsub %r{\-(?<arity>.*)\z}, '/\k<arity>'
          name.remove! 'Module:'
          name.prepend "#{self.name}:"
          [name, id]
        end
      end

      def entry_nodes
        @entry_nodes ||= css('div.REFBODY + p > a')
      end
    end
  end
end
