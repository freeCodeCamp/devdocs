module Docs
  class Dom < Mdn

    # release = '2021-10-22'
    self.name = 'DOM'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/API'

    html_filters.push 'dom/clean_html', 'dom/entries'

    options[:title] = 'Web API'
    options[:root_title] = 'Web API'

  end
end
