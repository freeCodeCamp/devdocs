module Docs
  class ApplyBaseUrlFilter < Filter
    URL_ATTRIBUTES = { 'a': 'href', 'img': 'src', 'iframe': 'src' }
    SCHEME_RGX = /\A[^:\/?#]+:/

    def call
      base_url = at_css('base').try(:[], 'href')
      return doc unless base_url

      URL_ATTRIBUTES.each_pair do |tag, attribute|
        css(tag).each do |node|
          next unless value = node[attribute]
          next if !relative_url_string?(value) || value[0] == '/'.freeze
          node[attribute] = "#{base_url}#{node[attribute]}"
        end
      end

      doc
    end
  end
end
