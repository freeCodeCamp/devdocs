module Docs
  class Cakephp
    class Entries39PlusFilter < Docs::EntriesFilter
      def page_type
        @page_type ||= slug.split('-').first
      end

      def slug_without_page_type
        @slug_without_page_type ||= slug.split('-').last
      end

      def get_name
        case page_type
        when 'class', 'trait', 'interface'
          slug.split('.').last.concat(" (#{self.page_type})")
        when 'namespace'
          slug_without_page_type.split('.').tap do |path|
            path.shift if path.length > 1
          end.join('\\').concat(" (namespace)")
        end
      end

      def get_type
        case page_type
        when 'class', 'trait', 'interface'
          slug_without_page_type.split('.')[1..-2].join('\\')
        when 'namespace'
          slug_without_page_type.split('.')[1..-1].join('\\')
        end
      end

      def additional_entries
        return [] unless page_type == 'class'
        class_name = slug.split('.').last
        return [] if class_name.end_with?('Exception')
        entries = []

        css('h3.method-name').each do |node|
          method_name = node['id'].concat('()')
          entries << ["#{class_name}::#{method_name}", node['id']]
        end

        css('h3.property-name').each do |node|
          property_name = node['id']
          entries << ["#{class_name}::#{property_name}", node['id']]
        end

        entries
      end
    end
  end
end
