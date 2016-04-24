module Docs
  class ApachePig
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        at_css('h1').content
      end

      def additional_entries
        nodes = case slug
        when 'basic', 'cmds', 'func'
          css('h3')
        when 'cont'
          css('h2, #macros + div > h3')
        when 'test'
          css('h2, #diagnostic-ops + div > h3')
        when 'perf'
          css('h2, #optimization-rules + div > h3, #specialized-joins + div > h3')
        else
          css('h2')
        end

        nodes.each_with_object [] do |node, entries|
          name = node.content.strip
          entries << [name, node['id']] unless name == 'Introduction'
        end
      end
    end
  end
end
