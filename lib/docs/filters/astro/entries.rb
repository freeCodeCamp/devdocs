module Docs
  class Astro
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('article h1').content
        name.sub! %r{\s*#\s*}, ''
        name
      end

      def get_type
        return 'Guides' if slug.start_with?('contribute/')
        return 'Guides' if slug.start_with?('guides/')
        aside = at_css('aside')
        a = aside.at_css('a[aria-current="page"]', 'a[data-current-parent="true"]')
        a.ancestors('details').at_css('summary').content
      end

      def additional_entries
        return [] if slug.start_with?('guides/deploy')
        return [] if slug.start_with?('guides/integrations-guide')
        at_css('article').css('h2[id], h3[id]').each_with_object [] do |node, entries|
          type = node.content.strip
          type.sub! %r{\s*#\s*}, ''
          entries << ["#{name}: #{type}", node['id']]
        end
      end
    end
  end
end
