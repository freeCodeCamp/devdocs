module Docs
  class Bun
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').try(:content) || at_css('h2').content
      end

      def get_type
        # Slugs are prefixed with the site section: "docs/runtime/sqlite",
        # "guides/runtime/typescript". Group the docs by their own section.
        parts = slug.split('/')
        parts.first == 'docs' ? parts.fetch(1, 'docs') : parts.first
      end

      def additional_entries
        if slug.start_with?('docs/pm/cli')
          heading_entries { |heading| "#{get_name} #{heading}" }
        elsif slug.start_with?('docs/runtime')
          heading_entries { |heading| "#{get_name}: #{heading}" }
        else
          []
        end
      end

      private

      def heading_entries
        css('h2[id]').each_with_object [] do |node, entries|
          entries << [yield(node.content.strip), node['id']]
        end
      end
    end
  end
end
