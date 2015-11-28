module Docs
  class Docker
    class EntriesFilter < Docs::EntriesFilter
      def get_name
        title = at_css('h1').content

        title = title.split(' — ').first
        title = title.split(' - ').first

        title
      end

      def get_type
        if slug.count('/') == 1 or slug.count('/') == 2
           slug.split('/').first.capitalize
        else
          slug.split('/')[0...-1].map(&:capitalize).join('/').gsub(/\-|\_/, ' ')
        end
      end
    end
  end
end
