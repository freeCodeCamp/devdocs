module Docs
  class Pandas
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if subpath.start_with?('generated')
          name = at_css('dt').content.strip
          name.sub! %r{\(.*}, '()'
          name.remove! %r{\s=.*}
          name.remove! %r{\A(class(method)?) (pandas\.)?}
        else
          name = at_css('h1').content.strip
          name.prepend "#{css('.toctree-l1 > a:not([href^="http"])').to_a.index(at_css('.toctree-l1.current > a')) + 1}. "
        end
        name.remove! "\u{00B6}"
        name
      end

      def get_type
        if subpath.start_with?('generated')
          css('.toctree-l2.current > a').last.content.remove(/\s\(.+?\)/)
        else
          'Manual'
        end
      end
    end
  end
end
