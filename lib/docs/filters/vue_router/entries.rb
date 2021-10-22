module Docs
  class VueRouter
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.sub! %r{#\s*}, ''
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
          entry_name = node.content.strip

          # Get the previous h2 title
          title = node
          title = title.previous_element until title.name == 'h2'
          title = title.content.strip
          title.sub! %r{#\s*}, ''

          entry_name.sub! %r{#\s*}, ''

          case title
          when 'Router Construction Options'
            entry_name = "RouterOptions.#{entry_name}"
          when '<router-view> Props'
            entry_name = "<router-view> `#{entry_name}` prop"
          when '<router-link> Props'
            entry_name = "<router-link> `#{entry_name}` prop"
          when 'Router Instance Methods'
            entry_name = "#{entry_name}()"
          end

          entry_name = entry_name.split(' API ')[0] if entry_name.start_with?('v-slot')

          unless title == "Component Injections" || node['id'] == 'route-object-properties'
            entries << [entry_name, node['id'], 'API Reference']
          end
        end

        css('#route-object-properties + ul > li > p:first-child > strong').each do |node|
          entry_name = node.content.strip
          id = "route-object-#{entry_name.remove('$route.')}"

          node['id'] = id
          entries << [entry_name, node['id'], 'API Reference']
        end

        entries
      end
    end
  end
end
