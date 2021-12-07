module Docs
  class Dom < Mdn

    # release = '2021-12-07'
    self.name = 'Web APIs'
    self.slug = 'dom'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/API'

    html_filters.push 'dom/clean_html', 'dom/entries'

    options[:root_title] = 'Web APIs'

  end
end
