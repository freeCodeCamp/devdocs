module Docs
  class Javascript < Mdn
    prepend FixInternalUrlsBehavior
    prepend FixRedirectionsBehavior

    # release = '2025-09-15'
    self.name = 'JavaScript'
    self.base_url = 'https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference'
    self.links = {
      home: 'https://developer.mozilla.org/en-US/docs/Web/JavaScript',
      code: 'https://github.com/mdn/content/tree/main/files/en-us/web/javascript'
    }

    html_filters.push 'javascript/clean_html', 'javascript/entries'

    options[:root_title] = 'JavaScript'

    # Duplicates
    options[:skip] = %w(
      /Global_Objects
      /Operators
      /Statements)

    options[:skip_patterns] = [
      /contributors.txt/,
      /Deprecated_and_obsolete_features/
    ]

    options[:fix_urls] = ->(url) do
      url.sub! '%2A', '*'
      url.sub! '%40', '@'
      url
    end
  end
end
