module Docs
  class Dom < Mdn

    self.name = 'DOM'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/API'

    html_filters.push 'dom/clean_html', 'dom/entries', 'title'

    options[:root_title] = 'DOM'

    # self.release = '2021-04-29'

  end
end
