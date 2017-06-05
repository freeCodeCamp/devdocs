module Docs
  class Immutablejs
    class InternalUrlsFilter < Docs::InternalUrlsFilter
      def update_and_follow_links
        urls = result[:internal_urls] = []
        update_links do |url|
          urls << url.to_s
        end
        urls.uniq!
      end

      def to_internal_url(str)
        if str.start_with? "#/"
          return nil if not str =~ /^#\/[^\/]+$/
          str = root_url.to_s + str
        end

        super(str)
      end

    end
  end
end
