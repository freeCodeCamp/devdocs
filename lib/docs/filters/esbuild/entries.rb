module Docs
  class Esbuild
    class EntriesFilter < Docs::EntriesFilter
      def name
        at_css('h1').content
      end
      def type
        at_css('h1').content
      end

      def additional_entries
        entries = []
        type = at_css('h1').content
        css('h2[id], h3[id]').each do |node|
          entries << [node.content.gsub(/^#/, ''), node['id'], type]
        end
        entries
      end
    end
  end
end
