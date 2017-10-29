module Docs
  class Nginx
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip
        name.sub! %r{\AModule ngx}, 'ngx'
        name
      end

      def get_type
        if name.starts_with?('ngx_')
          name
        elsif slug == 'ngx_core_module'
          'Core'
        else
          'Guides'
        end
      end

      def additional_entries
        css('h1 + ul a').each_with_object [] do |node, entries|
          name = node.content.strip
          next if name =~ /\A[A-Z]/ || name.start_with?('/')

          id = node['href'].remove('#')
          next if id.blank?

          entries << [name, id]
        end
      end
    end
  end
end
