module Docs
  class Cakephp
    class EntriesFilter < Docs::EntriesFilter
      def page_type
        @page_type ||= slug.split('-').first
      end

      def slug_without_page_type
        @slug_without_page_type ||= slug.split('-').last
      end

      def get_name
        case page_type
        when 'class'
          slug_without_page_type.split('.').last.concat(' (class)')
        when 'function'
          at_css('h1').content.remove('Function ')
        when 'namespace', 'package'
          slug_without_page_type.split('.').tap do |path|
            path.shift if path.length > 1
          end.join('\\').concat(" (#{page_type})")
        end
      end

      def get_type
        return 'Global' if slug == 'namespace-None'
        case page_type
        when 'class', 'namespace', 'package'
          if (node = at_css('.info')) && node.content =~ /Location:\s+((?:\w+\/?)+)/ # for 2.x docs
            path = $1.split('/')
          else
            path = slug_without_page_type.split('.')
          end
          path.shift if path.length > 1 && path[0] == 'Cake'
          path.pop if path.length > 1
          path.pop if path.last == 'Exception'
          path.join('\\')
        when 'function'
          'Global'
        end
      end

      def additional_entries
        return [] unless page_type == 'class'
        class_name = name.remove(' (class)')
        return [] if class_name.end_with?('Exception')
        entries = []

        css('h3.method-name').each do |node|
          break if node.parent.previous_element.content =~ /\AMethods.*from/
          entries << ["#{class_name}::#{node.at_css('.name').content.strip}", node['id']]
        end

        css('h3.property-name').each do |node|
          break if node.parent.parent['class'].include?('used')
          entries << ["#{class_name}::#{node.at_css('.name').content.strip}", node['id']]
        end

        entries
      end
    end
  end
end
