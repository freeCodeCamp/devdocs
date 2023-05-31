module Docs
  class Dom < Mdn

    # release = '2023-04-24'
    self.name = 'Web APIs'
    self.slug = 'dom'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/API'
    self.links = {
      home: 'https://developer.mozilla.org/en-US/docs/Web/API',
      code: 'https://github.com/mdn/content/tree/main/files/en-us/web/api'
    }

    html_filters.push 'dom/clean_html', 'dom/entries'

    options[:root_title] = 'Web APIs'

  end
end
