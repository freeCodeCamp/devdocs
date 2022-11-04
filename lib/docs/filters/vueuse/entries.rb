module Docs
  class Vueuse
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content
        name.sub! %r{\s*#\s*}, ''
        name
      end

      def get_type
        return 'Guide' if slug == 'export-size'
        return 'Guide' if slug == 'functions'
        link = at_css('aside .link.active')
        link.ancestors('section').at_css('.title').content
      end
    end
  end
end
