module Docs
  class Twig
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        name = at_css('h1').content.strip.tr('¶', '')
        name
      end

      def get_type
        if slug.include?('deprecate')
          'Deprecated'
        elsif slug.include?('extensions')
          'Doc\\Extensions'
        elsif slug.include?('tags')
          'tags'
        elsif slug.include?('filters')
          'filters'
        elsif slug.include?('functions')
          'functions'
        elsif slug.include?('tests')
          'tests'
        elsif slug.include?('-operator') || slug.include?('#math') || slug.include?('comparisons')
          'operators'
        elsif slug.in?('doc/index') || slug.include?('intro') || slug.include?('recipes') || slug.include?('internals') || slug.include?('coding_standards') || slug.include?('installation') ||  slug.include?('api') || slug.include?('advanced')
          'Doc'
        elsif slug.include?('templates')
          'Doc\\Templates'
        end
      end

    end
  end
end
