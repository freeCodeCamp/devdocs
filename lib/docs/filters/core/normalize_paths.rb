# frozen_string_literal: true

module Docs
  class NormalizePathsFilter < Filter
    def call
      result[:path] = path
      result[:store_path] = store_path

      css('a').each do |link|
        next unless (href = link['href']) && relative_url_string?(href)
        link['href'] = normalize_href(href)
      end

      doc
    end

    def path
      @path ||= root_page? ? 'index' : normalized_subpath
    end

    def store_path
      File.extname(path) != '.html' ? "#{path}.html" : path
    end

    def normalized_subpath
      normalize_path subpath.remove(/\A\//)
    end

    def normalize_href(href)
      url = URL.parse(href)
      url.send(:set_path, normalize_path(url.path))
      url
    rescue URI::InvalidURIError
      href
    end

    def normalize_path(path)
      path = path.downcase

      if context[:decode_and_clean_paths]
        path = CGI.unescape(path)
        path = clean_path(path)
      end

      if path == '.'
        'index'
      elsif path.end_with? '/'
        "#{path}index"
      elsif path.end_with? '.html'
        path[0..-6]
      else
        path
      end
    end
  end
end
