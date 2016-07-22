module Docs
  class Pig
    class EntriesFilter < Docs::EntriesFilter

      def include_default_entry?
        false
      end

      def get_type
        at_css('h1').content
      end

      def additional_entries
        case slug
          when 'basic', 'cmds', 'func'
            nodes = css('h3')
          when 'cont'
            nodes = css('h2, #macros + div > h3')
          when 'test'
            nodes = css('h2, #diagnostic-ops + div > h3')
          when 'perf'
            nodes = css('h2, #optimization-rules + div > h3, #specialized-joins + div > h3')
          else
            nodes = css('h2')
        end

        nodes.each_with_object [] do |node, entries|
          entries << [node.content, node['id'], get_type]
        end
      end
    end
  end
end
