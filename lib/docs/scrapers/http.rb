module Docs
  class Http < Mdn
    include MultipleBaseUrls

    # release = '2022-11-17'
    self.name = 'HTTP'
    self.base_urls = [
      'https://developer.mozilla.org/en-US/docs/Web/HTTP',
      'https://datatracker.ietf.org/doc/html/',
    ]
    self.links = {
      home: 'https://developer.mozilla.org/en-US/docs/Web/HTTP',
      code: 'https://github.com/mdn/content/tree/main/files/en-us/web/http'
    }

    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2023 MDN contributors.<br>
      Licensed under the Creative Commons Attribution-ShareAlike License v2.5 or later.
    HTML

    html_filters.push 'http/clean_html', 'http/entries', 'title'

    options[:root_title] = 'HTTP'
    options[:title] = ->(filter) do
      filter.current_url.host == 'datatracker.ietf.org' ? false : filter.default_title
    end
    options[:container] = ->(filter) do
      filter.current_url.host == 'datatracker.ietf.org' ? '.content' : Docs::Mdn.options[:container]
    end
    options[:skip_links] = ->(filter) do
      filter.current_url.host == 'datatracker.ietf.org'
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
         https://datatracker.ietf.org/doc/html/rfc4918
         https://datatracker.ietf.org/doc/html/rfc9110
         https://datatracker.ietf.org/doc/html/rfc9111
         https://datatracker.ietf.org/doc/html/rfc9112
         https://datatracker.ietf.org/doc/html/rfc9113
         https://datatracker.ietf.org/doc/html/rfc9114
         https://datatracker.ietf.org/doc/html/rfc5023)
    end
  end
end
