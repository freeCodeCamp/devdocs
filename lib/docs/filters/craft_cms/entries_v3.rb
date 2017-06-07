module Docs
  class CraftCms
    class EntriesV3Filter < Docs::EntriesFilter
      
      def get_name
        name = at_css('h1').content.strip
        name
      end

      def get_type
        if slug.start_with?('docs')
          type = slug.split('/').drop(1).first
          
          docs_patterns = [/folder/, /upgrading/, /writing\-plugins/, /installing/]
          docs_regex = Regexp.union(docs_patterns)
          
          if type.nil?
            'Docs'
          elsif type.match(docs_regex)
            if type.include?('plugins')
              'Docs\\Plugins'
            else
              'Docs'
            end
          else
            type
          end
        else
          'Guide'
        end
      end

      def additional_entries
        
        
        # Get Class Name from get_name method
        classname = get_name
        entry_type = get_type

        css('h2').each_with_object [] do |node, entries|
          # Get Property Name, Method Name, etc
          name = node.content.strip.tr('#', '')
          label = classname + "#" +  name

          tag  = node.at_css('a')['id']
          
          # Append to entries array
          entries << [label, tag, entry_type]
        end
      end

    end
  end
end
