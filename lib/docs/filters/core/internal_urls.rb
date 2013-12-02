require 'set'

module Docs
  class InternalUrlsFilter < Filter
    def call
      return doc if skip_links?
      internal_urls = Set.new if follow_links?

      css('a').each do |link|
        next unless url = parse_href(link['href'])
        next unless subpath = subpath_to(url)

        normalize_subpath(subpath)

        next if skip_subpath?(subpath)

        normalize_internal_url(url, subpath)

        link['href'] = internal_path_to(url)
        internal_urls << url.merge!(fragment: nil).to_s if internal_urls
      end

      result[:internal_urls] = internal_urls.to_a if internal_urls
      doc
    end

    def skip_links?
      context[:skip_links].is_a?(Proc) ? context[:skip_links].call(self) : context[:skip_links]
    end

    def follow_links?
      !(context[:follow_links] && context[:follow_links].call(self) == false)
    end

    def parse_href(str)
      str && absolute_url_string?(str) && URL.parse(str)
    rescue URI::InvalidURIError
      nil
    end

    def normalize_subpath(path)
      case context[:trailing_slash]
      when true
        path << '/' unless path.end_with?('/')
      when false
        path.slice!(-1) if path.end_with?('/')
      end
    end

    def skip_subpath?(path)
      if context[:only] || context[:only_patterns]
        return true unless context[:only].try(:any?) { |value| path.casecmp(value) == 0 } ||
                           context[:only_patterns].try(:any?) { |value| path =~ value }
      end

      if context[:skip] || context[:skip_patterns]
        return true if context[:skip].try(:any?) { |value| path.casecmp(value) == 0 } ||
                       context[:skip_patterns].try(:any?) { |value| path =~ value }
      end

      false
    end

    def normalize_internal_url(url, path)
      url.normalize!
      url.merge! path: base_url.path + path
    end

    def internal_path_to(url)
      url = index_url if url == root_url
      path = effective_url.relative_path_to(url)
      URL.new(path: path, query: url.query, fragment: url.fragment).to_s
    end

    def index_url
      @index_url ||= base_url.merge path: File.join(base_url.path, '')
    end

    def effective_url
      @effective_url ||= current_url == root_url ? index_url : current_url
    end
  end
end
