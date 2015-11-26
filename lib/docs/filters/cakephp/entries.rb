module Docs
  class Cakephp
    class EntriesFilter < Docs::EntriesFilter
      INCLUDE_PAGE_TYPES = {
        'class'     => true,
        'function'  => true,
        'namespace' => false,
      }

      def get_page_type
        page_type = slug.split('-')[0]
      end

      def include_default_entry?
        INCLUDE_PAGE_TYPES[get_page_type]
      end

      def get_name
        case get_page_type
          when 'class'
            slug.split('.').last
          when 'function'
            at_css('h1').content.split(' ')[1]
        end
      end

      def get_type
        case get_page_type
          when 'class'
            slug.split('.')[1..-2].join('\\')
          when 'function'
            'Global Functions'
        end
      end

      def additional_entries
        entries = []
        if get_page_type == 'class'
          css('.method-name').each do |node|
            name = get_name + '::' + node.at_css('.name').content.strip + '()'
            id = node['id']
            entries << [name, id, get_type]
          end
          css('.property-name').each do |node|
            name = get_name + '::' + node.at_css('.name').content.strip
            id = node['id']
            entries << [name, id, get_type]
          end
        end
        entries
      end

    end
  end
end
