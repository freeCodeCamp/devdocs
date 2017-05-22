module Docs
  class Statsmodels
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if subpath.start_with?('generated')
          name = at_css('dt').content.strip
          name.sub! %r{\(.*}, '()' # Remove method arguments
          name.remove! %r{[\=\[].*} # Remove "[source]"
          name.remove! %r{\A(class(method)?) }
          name.remove! %r{\Astatsmodels\.}
        else
          name = at_css('h1', 'h2').content.strip
          name.prepend 'Manual: ' if type == 'Manual'
          name.prepend 'Example: ' if type == 'Examples'
        end
        name.remove! "\u{00B6}" # Remove ¶
        name
      end

      def get_type
        if subpath.start_with?('generated')
          # '> text()' doesn't include children's text in type naming
          at_xpath('//div[@class="related"]//li[not(@class="right")][7]/a/text()').content

        elsif subpath.start_with?('examples')
          'Examples'
        else
          'Manual'
        end
      end
    end
  end
end
