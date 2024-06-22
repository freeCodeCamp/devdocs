module Docs
  class Jq
    class EntriesFilter < Docs::EntriesFilter
      def include_default_entry?
        false
      end

      def additional_entries
        entries = []
        css('> section').each do |node|
          type = node.at_css('h2').content
          node.css('> section').each do |n|
            entries << [n.at_css('h3').content, n['id'], type]
          end
        end
        return entries
      end
    end
  end
end
