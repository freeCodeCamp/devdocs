module Docs
  class Vuex
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content

        name.sub! %r{#\s*}, ''

        # Add index on guides
        unless subpath.start_with?('api')
          sidebar_link = at_css('.sidebar-link.active')
          all_links = css('.sidebar-link:not([href="/"]):not([href="../index"])')

          index = all_links.index(sidebar_link)

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
          entry_name = node.content.strip

          # Get the previous h2 title
          title = node
          title = title.previous_element until title.name == 'h2'
          title = title.content.strip
          title.sub! %r{#\s*}, ''

          entry_name.sub! %r{#\s*}, ''

          unless entry_name.start_with?('router.')
            case title
            when "Vuex.Store Constructor Options"
              entry_name = "StoreOptions.#{entry_name}"
            when "Vuex.Store Instance Properties"
              entry_name = "Vuex.Store.#{entry_name}"
            when "Vuex.Store Instance Methods"
              entry_name = "Vuex.Store.#{entry_name}()"
            when "Component Binding Helpers"
              entry_name = "#{entry_name}()"
            end
          end

          entries << [entry_name, node['id'], 'API Reference']
        end

        entries
      end
    end
  end
end
