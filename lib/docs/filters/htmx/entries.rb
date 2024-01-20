module Docs
  class Htmx
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').content
      end

      def get_type
        if slug.start_with?('attributes')
          'Attributes'
        elsif slug.start_with?('headers')
          'Headers'
        elsif slug.start_with?('events')
          'Events'
        elsif slug.start_with?('extensions')
          'Extensions'
        else
          get_name
        end
      end
      
      def additional_entries
        css('h3[id]:has(code)').each_with_object [] do |node, entries|
          name = node.at_css('code').content
          id = node['id']
          entries << [name, id]
        end
      end
    end
  end
end
