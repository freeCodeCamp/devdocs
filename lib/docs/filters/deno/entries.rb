module Docs
  class Deno
    class EntriesFilter < Docs::EntriesFilter

      def get_name
        if result[:path].start_with?('api/deno/')
          at_css('main[id!="content"]')['id'][/\Asymbol_([.\w]+)/, 1]
        else
          at_css('main article h1').content
        end
      end

      def get_type
        if result[:path].start_with?('api/deno/')
          'API'
        elsif result[:path].start_with?('runtime/reference/cli')
          'CLI'
        else
          at_css('main article nav ul :first span').content
        end
      end

    end
  end
end
