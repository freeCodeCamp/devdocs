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
        next if fragment_url_string?(value)
        node[attribute] = normalize_url(value)
      end
    end

    def normalize_url(str)
      url = to_absolute_url(str)
      fix_url(url)
      fix_url_string(url.to_s)
    rescue URI::InvalidURIError
      '#'
    end

    def to_absolute_url(str)
      url = URL.parse(str)
      url.relative? ? current_url.join(url) : url
    end

    def fix_url(url)
      return unless context[:replace_paths]
      path = subpath_to(url)

      if context[:replace_paths].has_key?(path)
        url.path = url.path.sub %r[#{path}\z], context[:replace_paths][path]
      end
    end

    def fix_url_string(str)
      str = context[:replace_urls][str]  || str if context[:replace_urls]
      str = context[:fix_urls].call(str) || str if context[:fix_urls]
      str
    end
  end
end
