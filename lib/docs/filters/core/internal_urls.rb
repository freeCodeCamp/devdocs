# frozen_string_literal: true

module Docs
  class InternalUrlsFilter < Filter
    def call
      result[:subpath] = subpath

      unless skip_links?
        follow_links? ? update_and_follow_links : update_links
      end

      doc
    end

    def update_links
      css('a').each do |link|
        next if context[:skip_link].is_a?(Proc) && context[:skip_link].call(link)
        next unless url = to_internal_url(link['href'])
        link['href'] = internal_path_to(url)
        yield url if block_given?
      end
    end

    def update_and_follow_links
      urls = result[:internal_urls] = []
      update_links do |url|
        urls << url.merge!(fragment: nil).to_s
      end
      urls.uniq!
    end

    def skip_links?
      return context[:skip_links].call(self) if context[:skip_links].is_a?(Proc)
      return true if context[:skip_links]
      false
    end

    def follow_links?
      return false if context[:follow_links] == false
      return false if context[:follow_links].is_a?(Proc) && context[:follow_links].call(self) == false
      true
    end

    def to_internal_url(str)
      return unless (url = parse_url(str)) && (subpath = subpath_to(url))
      normalize_subpath(subpath)
      return if skip_subpath?(subpath)
      normalize_url(url, subpath)
      url
    end

    def parse_url(str)
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

    def normalize_url(url, subpath)
      url.merge! path: base_url.path + subpath
      url.normalize!
    end

    def internal_path_to(url)
      url = index_url if url == root_url
      path = effective_url.relative_path_to(url)
      path = clean_path(path) if context[:decode_and_clean_paths]
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
