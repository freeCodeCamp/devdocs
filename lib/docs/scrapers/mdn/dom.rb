module Docs
  class Dom < MdnGit
    # release = '2026-09-14'
    self.name = 'Web APIs'
    self.slug = 'dom'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/API'
    self.content_path = 'web/api'
    self.slug_prefix = 'Web/API'
    self.links = {
      home: 'https://developer.mozilla.org/en-US/docs/Web/API',
      code: 'https://github.com/mdn/content/tree/main/files/en-us/web/api'
    }

    html_filters.push 'dom/entries'

    options[:root_title] = 'Web APIs'
  end
end
