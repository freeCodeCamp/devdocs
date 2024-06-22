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
        if slug.start_with?('architecture')
          'Architecture'
        elsif slug.start_with?('community')
          'Community'
        elsif slug.start_with?('getting-started')
          'Getting Started'
        elsif slug.start_with?('messages')
          'Messages'
        elsif slug.start_with?('app/building-your-application')
          'Using App Router: Building your application'
        elsif slug.start_with?('app/api-reference')
          'Using App Router: api-reference'
        elsif slug.start_with?('app')
          'Using App Router'
        elsif slug.start_with?('pages/building-your-application')
          'Using Pages Router: Building your application'
        elsif slug.start_with?('pages/api-reference')
          'Using Pages Router: api-reference'
        elsif slug.start_with?('pages')
          'Using Pages Router'
        else
          get_name
        end
      end
    end
  end
end
