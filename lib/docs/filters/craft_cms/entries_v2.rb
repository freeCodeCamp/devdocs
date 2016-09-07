module Docs
  class CraftCms
    class EntriesV2Filter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name
      end

      def get_type
          components = slug.split('/')
          type = components.first
          type
      end
      
      def additional_entries
        classname = at_css('h1').content.strip
        css('header.h3 h3').each_with_object [] do |node, entries|
          name = node.at_css('code').content.strip
          label = classname + " " +  name
          tag  = name.tr('()', '') + '-detail'
          entries << [label, tag]
        end
      end
    end
  end
end
