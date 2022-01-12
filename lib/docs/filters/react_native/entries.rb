module Docs
  class ReactNative
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        at_css('h1').children.select(&:text?).map(&:content).join.strip
      end

      def get_type
        type = at_css('.navbar__link--active')
        return 'Miscellaneous' unless type
        type.content.strip
      end

      def additional_entries
        css('main .col .markdown h3').each_with_object [] do |node, entries|
          code = node.at_css('code')
          next unless code
          subname = code.text
          next if subname.blank? || node.css('code').empty?
          sep = subname.include?('()') ? '.' : '#'
          subname.prepend(name + sep)
          id = node['id']
          entries << [subname, id]
        end
      end
    end
  end
end
