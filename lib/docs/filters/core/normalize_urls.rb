# frozen_string_literal: true

module Docs
  class NormalizeUrlsFilter < Filter
    ATTRIBUTES = { a: 'href', img: 'src', iframe: 'src' }

    def call
      ATTRIBUTES.each_pair do |tag, attribute|
        update_attribute(tag, attribute)
      end
      doc
    end

    def update_attribute(tag, attribute)
      css(tag.to_s).each do |node|
        next unless value = node[attribute]
        next if fragment_url_string?(value) || data_url_string?(value)
        node[attribute] = normalize_url(value) || (tag == :iframe ? value : '#')
      end
    end

    def normalize_url(str)
      str.strip!
      str.gsub!(' ', '%20')
      str = context[:fix_urls_before_parse].call(str) if context[:fix_urls_before_parse]
      url = to_absolute_url(str)

      while new_url = fix_url(url)
        url = new_url
      end

      url.to_s
    rescue URI::InvalidURIError
      nil
    end

    def to_absolute_url(str)
      url = URL.parse(str)
      url.relative? ? current_url.join(url) : url
    end

    def fix_url(url)
      if context[:redirections]
        url = URL.parse(url)
        path = url.path.downcase

        if context[:redirections].key?(path)
          url.path = context[:redirections][path]
          return url
        end
      end

      if context[:replace_paths]
        url = URL.parse(url)
        path = subpath_to(url)

        if context[:replace_paths].key?(path)
          url.path = url.path.sub %r[#{path}\z], context[:replace_paths][path]
          return url
        end
      end

      if context[:replace_urls]
        url = url.to_s

        if context[:replace_urls].key?(url)
          return context[:replace_urls][url]
        end
      end

      if context[:fix_urls]
        url = url.to_s
        orig_url = url.dup
        new_url = context[:fix_urls].call(url)
        return new_url if new_url != orig_url
      end
    end
  end
end
