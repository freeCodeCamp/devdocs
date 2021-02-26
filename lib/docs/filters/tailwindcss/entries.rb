module Docs
  class Tailwindcss
    class EntriesFilter < Docs::EntriesFilter
      # def get_name
      #   if api_page?
      #     name = at_css('h1').content.strip.remove('Illuminate\\')
      #     name << " (#{type})" unless name.start_with?(self.type)
      #     name
      #   else
      #     at_css('h1').content
      #   end
      # end

      def get_type
        # /customizing-colors rediects to /colors, hence making css
        # selector below not to match the href
        if result[:path] == 'customizing-colors'
          selector = "#sidebar a[href='#{result[:path]}']"
        else
          selector = "#sidebar a[href='#{result[:path]}']"
        end

        check = at_css(selector).parent.parent.parent.css('h5').inner_text
        check
      end

      # def additional_entries
      #   return [] if root_page? || !api_page?
      #   base_name = self.name.remove(/\(.+\)/).strip

      #   css('h3[id^="method_"]').each_with_object [] do |node, entries|
      #     next if node.at_css('.location').content.start_with?('in')

      #     name = node['id'].remove('method_')
      #     name.prepend "#{base_name}::"
      #     name << '()'

      #     entries << [name, node['id']]
      #   end
      # end

      # def api_page?
      #   subpath.start_with?('/api')
      # end

      # def include_default_entry?
      #   true
      # end
    end
  end
end
