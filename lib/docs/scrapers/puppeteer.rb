module Docs
  class Puppeteer < Github
    self.release = '1.8.0'
    self.base_url = 'https://github.com/GoogleChrome/puppeteer/blob/v1.8.0/docs/api.md'
    self.links = {
      code: 'https://github.com/GoogleChrome/puppeteer'
    }

    html_filters.push 'puppeteer/entries', 'puppeteer/clean_html'

    options[:container] = '.markdown-body'

    options[:attribution] = <<-HTML
      &copy; 2017 Google Inc<br>
      Licensed under the Apache License 2.0.
    HTML
  end
end
