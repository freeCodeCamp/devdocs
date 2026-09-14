module Docs
  class Javascript < MdnGit
    # release = '2026-09-14'
    self.name = 'JavaScript'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference'
    self.content_path = 'web/javascript/reference'
    self.slug_prefix = 'Web/JavaScript/Reference'
    self.links = {
      home: 'https://developer.mozilla.org/en-US/docs/Web/JavaScript',
      code: 'https://github.com/mdn/content/tree/main/files/en-us/web/javascript'
    }

    html_filters.push 'javascript/entries'

    options[:root_title] = 'JavaScript'

    # Pages that repeat what their subpages or the reference index already say.
    options[:skip] = %w(/Global_Objects /Operators /Statements)
    options[:skip_patterns] = [/Deprecated_and_obsolete_features/]

    options[:fix_urls] = ->(url) do
      url.sub! '%2A', '*'
      url.sub! '%40', '@'
      url
    end
  end
end
