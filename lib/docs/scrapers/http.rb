module Docs
  class Http < Mdn
    include MultipleBaseUrls

    # release = '2021-10-22'
    self.name = 'HTTP'
    self.base_urls = [
      'https://developer.mozilla.org/en-US/docs/Web/HTTP',
      'https://datatracker.ietf.org/doc/html/',
    ]

    html_filters.push 'http/clean_html', 'http/entries', 'title'

    options[:root_title] = 'HTTP'
    options[:title] = ->(filter) do
      filter.current_url.host == 'datatracker.ietf.org' ? false : filter.default_title
    end
    options[:container] = ->(filter) do
      filter.current_url.host == 'datatracker.ietf.org' ? '.content .draftcontent' : Docs::Mdn.options[:container]
    end
    options[:skip_links] = ->(filter) do
      filter.current_url.host == 'datatracker.ietf.org' ? true : false
    end
    options[:replace_paths] = { '/Access_control_CORS' => '/CORS' }
    options[:fix_urls] = ->(url) do
      url.sub! %r{(Status/\d\d\d)_[A-Z].+}, '\1'
      url
    end

    options[:attribution] = ->(filter) do
      if filter.current_url.host == 'datatracker.ietf.org'
        "&copy; document authors. All rights reserved."
      else
        Docs::Mdn.options[:attribution]
      end
    end

    def initial_urls
      %w(https://developer.mozilla.org/en-US/docs/Web/HTTP
         https://datatracker.ietf.org/doc/html/rfc2616
         https://datatracker.ietf.org/doc/html/rfc4918
         https://datatracker.ietf.org/doc/html/rfc7230
         https://datatracker.ietf.org/doc/html/rfc7231
         https://datatracker.ietf.org/doc/html/rfc7232
         https://datatracker.ietf.org/doc/html/rfc7233
         https://datatracker.ietf.org/doc/html/rfc7234
         https://datatracker.ietf.org/doc/html/rfc7235
         https://datatracker.ietf.org/doc/html/rfc7540
         https://datatracker.ietf.org/doc/html/rfc5023)
    end
  end
end
