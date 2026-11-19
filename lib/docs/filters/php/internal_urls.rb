module Docs
  class Php
    class InternalUrlsFilter < Filter
      def call
        return doc if context[:fixed_internal_urls]

        if subpath.start_with?('book.') || subpath.start_with?('class.')
          result[:internal_urls] = internal_urls
        end

        doc
      end

      SKIP_URL_PATTERN = /\.(setup|requirements|installation|configuration)\.html\z/

      def internal_urls
        css('.book a', '.chunklist a').inject [] do |urls, link|
          urls << link['href'] if link.next.try(:text?) && link['href'].exclude?('ref.pdo-') && link['href'] !~ SKIP_URL_PATTERN
          urls
        end
      end
    end
  end
end
