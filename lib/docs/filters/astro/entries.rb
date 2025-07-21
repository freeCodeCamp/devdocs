module Docs
  class Astro
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1') ? at_css('h1').content : at_css('h2').content
        name.sub!(/\s*#\s*/, '')
        name
      end

      def get_type
        return 'Contribute' if slug.start_with?('contribute/')

        a = at_css('a[aria-current="page"]')
        a ? a.content : 'Other'
      end

      def additional_entries
        return [] if root_page?
        return [] if slug.start_with?('guides/deploy')
        return [] if slug.start_with?('guides/integrations-guide')

        at_css('main').css('h2[id], h3[id]').each_with_object [] do |node, entries|
          type = node.content.strip
          type.sub!(/\s*#\s*/, '')
          entries << ["#{name}: #{type}", node['id']]
        end
      end
    end
  end
end
