module Docs
  class Vuex
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content

        name.remove! '# '

        # Add index on guides
        unless subpath.start_with?('api')
          sidebarLink = at_css('.sidebar-link.active')
          allLinks = css('.sidebar-link:not([href="/"]):not([href="../index"])')

          index = allLinks.index(sidebarLink)

          name.prepend "#{index + 1}. " if index
        end

        name
      end

      def get_type
        'Guide'
      end

      def include_default_entry?
        name != 'API Reference'
      end

      def additional_entries
        return [] unless subpath.start_with?('api') 

        entries = [
          ['Component Binding Helpers', 'component-binding-helpers', 'API Reference'],
          ['Store', 'vuex-store', 'API Reference'],
        ]

        css('h3').each do |node|
          entryName = node.content.strip

          # Get the previous h2 title
          title = node
          title = title.previous_element until title.name == 'h2'
          title = title.content.strip
          title.remove! '# '

          entryName.remove! '# '

          unless entryName.start_with?('router.')
            if title == "Vuex.Store Constructor Options"
              entryName = "StoreOptions.#{entryName}"
            elsif title == "Vuex.Store Instance Properties"
              entryName = "Vuex.Store.#{entryName}"
            elsif title == "Vuex.Store Instance Methods"
              entryName = "Vuex.Store.#{entryName}()"
            elsif title == "Component Binding Helpers"
              entryName = "#{entryName}()"
            end
          end

          entries << [entryName, node['id'], 'API Reference']
        end

        entries
      end
    end
  end
end