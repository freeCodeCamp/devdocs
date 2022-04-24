module Docs
  class Nix
    class EntriesFilter < Docs::EntriesFilter
      def include_default_entry?
        false
      end

      def additional_entries
        css('h2, h3[data-add-to-index]').flat_map do |node|
          node.css('code').map do |code|
            title = code.content
            index = title.rindex('.')
            type = title[0...index]
            name = title.match(/^[^\s]+/)[0]

            [name, node['id'], type]
          end
        end
      end
    end
  end
end
