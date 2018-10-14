module Docs
  class VueRouter
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content

        name.remove! '# '

        name
      end

      def get_type
        return 'Other Guides' if subpath.start_with?('guide/advanced')
        return 'Basic Guides' if subpath.start_with?('guide') || subpath.start_with?('installation')

        'API Reference'
      end

      def include_default_entry?
        name != 'API Reference'
      end

      def additional_entries
        return [] unless subpath.start_with?('api') 

        entries = [
          ['<router-link>', 'router-link', 'API Reference'],
          ['<router-view>', 'router-view', 'API Reference'],
          ['$route', 'the-route-object', 'API Reference'],
          ['Component Injections', 'component-injections', 'API Reference']
        ]

        css('h3').each do |node|
          entryName = node.content.strip

          # Get the previous h2 title
          title = node
          title = title.previous_element until title.name == 'h2'
          title = title.content.strip
          title.remove! '# '

          entryName.remove! '# '

          if title == "Router Construction Options"
            entryName = "RouterOptions.#{entryName}"
          elsif title == "<router-view> Props"
            entryName = "<router-view> `#{entryName}` prop"
          elsif title == "<router-link> Props"
            entryName = "<router-link> `#{entryName}` prop"
          elsif title == "Router Instance Methods"
            entryName = "#{entryName}()"
          end

          unless title == "Component Injections" || node['id'] == 'applying-active-class-to-outer-element' || node['id'] == 'route-object-properties'
            entries << [entryName, node['id'], 'API Reference']
          end
        end

        css('#route-object-properties + ul > li > p:first-child > strong').each do |node|
          entryName = node.content.strip
          id = "route-object-#{entryName.remove('$route.')}"

          node['id'] = id
          entries << [entryName, node['id'], 'API Reference']
        end

        entries
      end
    end
  end
end