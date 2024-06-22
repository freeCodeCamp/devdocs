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
        return 'Guide' if slug == 'guidelines'
        return 'Guide' if slug.start_with? 'guide'
        link = at_css('.is-link.is-active')
        link.ancestors('section').at_css('h2.text').content
      end
    end
  end
end
