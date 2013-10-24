module Docs
  class Http
    class EntriesFilter < Docs::EntriesFilter
      def get_type
        at_css('h1').content.gsub(/\A\s*HTTP\s+(.+)\s+Definitions\s*\z/, '\1').pluralize
      end

      def include_default_entry?
        false
      end

      def additional_entries
        return [] if root_page?

        css(type == 'Status Codes' ? 'h3' : 'h2').map do |node|
          [node.content, node['id']]
        end
      end
    end
  end
end
