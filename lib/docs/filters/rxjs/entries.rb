module Docs
  class Rxjs
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        # Get function name from path if it's inside api/index/function
        if subpath.start_with?('api/index/function/')
          name = subpath.split('/').last.sub(/\.html$/, '').titleize
          name += '()'
        else
          title = at_css('h1')
          name = title.nil? ? subpath.rpartition('/').last.titleize : title.content
          name.prepend "#{$1}. " if subpath =~ /\-pt(\d+)/
          name += '()' unless at_css('.api-type-label.function').nil?
        end
        name
      end

      def get_type
        if slug.start_with?('guide')
          'Guide'
        elsif slug == 'api/index'
          nil # Hide index page to avoid listing the full page in sidebar
        elsif slug.start_with?('api/index/function/')
          'Top-level Functions'
        elsif slug.start_with?('api/')
          slug.split('/')[1].titleize
        else
          'Miscellaneous'
        end
      end

      def additional_entries
        css('h3[id]').flat_map do |node|
          return [] unless node['name']
          [["#{name}.#{node['name']}()", node['id']]]
        end
      end
    end
  end
end
