module Docs
  class CraftCms
    class EntriesV2Filter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name
      end

      def get_type
        if slug.start_with?('classreference')
          type = slug.split('/').drop(1).first
          
          if type.nil?
            'Class Reference'
          else
            type
          end
          
        elsif slug.start_with?('docs')
          type = slug.split('/').drop(1).first
          
          coreconcepts_patterns = [/users/, /sections/, /entries/, /globals/, /assets/, /categories/, /tags/, /fields/, /relations/, /routing/, /searching/, /image-transforms/]
          coreconcepts_regex = Regexp.union(coreconcepts_patterns)
          
          if type.nil?
            'Docs'
            
          elsif type.include?('folder')
            'Docs'
            
          elsif type.include?('plugins')
            'Docs\\Plugins'
            
          elsif type.include?('config') || type.in?(%w(php-constants))
            'Docs\\Configuration'

          elsif type.in?(%w(requirements updating installing))
            'Docs\\Installing and Updating'

          elsif type.match(coreconcepts_regex)
            out = 'Docs\\Core Concepts'
            
            if type.include?('fields')
              out << "\\Fields"
            elsif type.include?('transforms') || type.include?('assets')
              out << "\\Assets"
            end
            
            out

          elsif type.include?('templating') || type.include?('twig')
            'Docs\\Templating'

          elsif type.include?('localization')
            'Docs\\Guides'

          else
            type
          end
        end
      end

      def additional_entries
        # Get Class Name from get_name method
        classname = get_name

        css('header.h3 h3').each_with_object [] do |node, entries|
          # Get Property Name, Method Name, etc
          name = node.at_css('code').content.strip
          label = classname + " " +  name

          # Set Property|Method id of <a> that is the same in clean_html_v2.rb
          tag  = name.tr('()', '') + '-detail'

          # Append to entries array
          entries << [label, tag]
        end
      end
    end
  end
end
