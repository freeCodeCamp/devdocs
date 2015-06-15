module Docs
  class Drupal
    class InternalUrlsFilter < Docs::InternalUrlsFilter
      def internal_path_to(url)
        url = index_url if url == root_url
        path = effective_url.relative_path_to(url)
        URL.new(path: Drupal::fixUri(path), query: url.query, fragment: url.fragment).to_s
      end
    end
  end
end

