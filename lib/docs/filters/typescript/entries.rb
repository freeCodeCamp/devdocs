module Docs
  class Typescript
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        at_css('h1') ? at_css('h1').content : at_css('h2').content
      end

      def get_type
        name
      end

      def additional_entries
        base_url.path == '/' ? tsconfig_entries : handbook_entries
      end

      def tsconfig_entries
        css('h3 > code').each_with_object [] do |node, entries|
          entries << [node.content, node.parent['id']]
        end
      end

      def handbook_entries
        css('h2').each_with_object [] do |node, entries|
          entries << [node.content, node['id']]
        end
      end

    end
  end
end
