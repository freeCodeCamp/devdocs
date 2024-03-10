module Docs
  class Nextjs
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.strip!
        #name
        subpath_items = subpath.split('/', -1)
        if subpath_items.length >= 5
          subpath_items[3].capitalize + ': ' + name # e.g. Routing: Defining Routes
        else
          name
        end
      end

      def get_type
        if subpath.include?('/architecture')
          'Architecture'
        elsif subpath.include?('/community')
          'Community'
        elsif subpath.include?('/getting-started')
          'Getting Started'
        elsif subpath.include?('/messages')
          'Messages'
        elsif subpath.include?('/app/building-your-application')
          'Using App Router: Building your application'
        elsif subpath.include?('/app/api-reference')
          'Using App Router: api-reference'
        elsif subpath.include?('/app')
          'Using App Router'
        elsif subpath.include?('/pages/building-your-application')
          'Using Pages Router: Building your application'
        elsif subpath.include?('/pages/api-reference')
          'Using Pages Router: api-reference'
        elsif subpath.include?('/pages')
          'Using Pages Router'
        else
          get_name
        end
      end
    end
  end
end
