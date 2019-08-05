module Docs
  class Http < Mdn
    include MultipleBaseUrls

    self.name = 'HTTP'
    self.base_urls = ['https://developer.mozilla.org/en-US/docs/Web/HTTP', 'https://tools.ietf.org/html/']

    html_filters.push 'http/clean_html', 'http/entries', 'title'

    options[:mdn_tag] = 'HTTP'

    options[:root_title] = 'HTTP'
    options[:title] = ->(filter) { filter.current_url.host == 'tools.ietf.org' ? false : filter.default_title }
    options[:container] = ->(filter) { filter.current_url.host == 'tools.ietf.org' ? '.content' : nil }
    options[:skip_links] = ->(filter) { filter.current_url.host == 'tools.ietf.org' ? true : false }
    options[:replace_paths] = { '/Access_control_CORS' => '/CORS' }
    options[:fix_urls] = ->(url) do
      url.sub! %r{(Status/\d\d\d)_[A-Z].+}, '\1'
      url
    end

    options[:attribution] = ->(filter) do
      if filter.current_url.host == 'tools.ietf.org'
        "&copy; document authors. All rights reserved."
      else
        Docs::Mdn.options[:attribution]
      end
    end

    def initial_urls
      %w(https://developer.mozilla.org/en-US/docs/Web/HTTP
         https://tools.ietf.org/html/rfc2616
         https://tools.ietf.org/html/rfc4918
         https://tools.ietf.org/html/rfc7230
         https://tools.ietf.org/html/rfc7231
         https://tools.ietf.org/html/rfc7232
         https://tools.ietf.org/html/rfc7233
         https://tools.ietf.org/html/rfc7234
         https://tools.ietf.org/html/rfc7235
         https://tools.ietf.org/html/rfc5023)
    end
  end
end
