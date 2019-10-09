module Docs
  class Puppeteer < Github
    self.release = '1.20.0'
    self.base_url = 'https://github.com/GoogleChrome/puppeteer/blob/v1.20.0/docs/api.md'
    self.links = {
      code: 'https://github.com/GoogleChrome/puppeteer'
    }

    html_filters.push 'puppeteer/entries', 'puppeteer/clean_html'

    options[:container] = '.markdown-body'

    options[:attribution] = <<-HTML
      &copy; 2017 Google Inc<br>
      Licensed under the Apache License 2.0.
    HTML

    def get_latest_version(opts)
      contents = get_github_file_contents('GoogleChrome', 'puppeteer', 'README.md', opts)
      contents.scan(/\/v([0-9.]+)\/docs\/api\.md/)[0][0]
    end
  end
end
