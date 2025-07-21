module Docs
  class Threejs
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        # Try to get name from the title first
        if title = at_css('.lesson-title h1')&.content
          title
        else
          # Fallback to path-based name for API docs
          slug.split('/').last.gsub('.html', '').titleize
        end
      end

      def get_type
        if slug.start_with?('api/en/')
          # For API documentation, use the section as type
          # e.g. "api/en/animation/AnimationAction" -> "Animation"
          path_parts = slug.split('/')
          if path_parts.length >= 3
            path_parts[2].titleize
          else
            'API'
          end
        elsif slug.start_with?('manual/en/')
          # For manual pages, get the section from the path
          # e.g. "manual/en/introduction/Creating-a-scene" -> "Introduction"
          path_parts = slug.split('/')
          if path_parts.length >= 3
            path_parts[2].titleize
          else
            'Manual'
          end
        else
          'Other'
        end
      end

      def additional_entries
        entries = []
        
        # Get all methods and properties from h3 headings
        css('h3').each do |node|
          name = node.content.strip
          # Skip if it's a constructor or doesn't have an ID
          next if name == get_name || !node['id']
          
          entries << [name, node['id'], get_type]
        end

        entries
      end
    end
  end
end 