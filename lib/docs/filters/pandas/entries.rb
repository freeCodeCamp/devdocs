module Docs
  class Pandas
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        if dt = at_css('dt')
          name = dt.content.strip
          name.sub! %r{\(.*}, '()'
          name.remove! %r{\s=.*}
          name.remove! %r{\A(class(method)?) }
        else
          name = at_css('h1').content.strip
        end
        name.remove! "\u{00B6}"
        name
      end

      def get_type
        css(".toctree-l2.current > a").last.content
      end
    end
  end
end
