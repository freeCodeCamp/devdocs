module Docs
  class Rxjs
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        title = at_css('h1')
        name = title.nil? ? subpath.rpartition('/').last.titleize : title.content
        name.prepend "#{$1}. " if subpath =~ /\-pt(\d+)/
        name += '()' unless at_css('.api-type-label.function').nil?
        name
      end

      def get_type
        if slug.start_with?('guide')
          'Guide'
        elsif slug.start_with?('api/')
          slug.split('/').second
        else
          'Miscellaneous'
        end
      end

      def additional_entries
        css('h3[id]').map do |node|
          ["#{name}.#{node['name']}()", node['id']]
        end
      end
    end
  end
end
