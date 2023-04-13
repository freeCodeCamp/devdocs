module Docs
  class Http < Mdn
    # release = '2022-11-17'
    self.name = 'HTTP'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/HTTP'

    html_filters.push 'http/clean_html', 'http/entries'

    options[:root_title] = 'HTTP'

    options[:replace_paths] = { '/Access_control_CORS' => '/CORS' }

    options[:fix_urls] = ->(url) do
      url.sub! %r{(Status/\d\d\d)_[A-Z].+}, '\1'
      url
    end

  end
end
