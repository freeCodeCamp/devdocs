module Docs
  # Firebase's guides, from firebase.google.com/docs. The API references are
  # left out: the JavaScript one is published as Markdown and makes a better
  # doc pack (github.com/buggypather/devdocs-pack-firebase).
  class Firebase < UrlScraper
    self.name = 'Firebase'
    self.type = 'simple'
    # The site isn't versioned: the release is the month it was scraped.
    self.release = Time.now.utc.strftime('%Y-%m')
    self.base_url = 'https://firebase.google.com/docs/'
    self.root_path = '/'
    self.links = {
      home: 'https://firebase.google.com/docs',
      code: 'https://github.com/firebase'
    }
    self.headers = { 'User-Agent' => 'DevDocs scraper (+https://github.com/buggypather/devdocs)' }

    html_filters.push 'firebase/entries', 'firebase/clean_html'

    options[:container] = '.devsite-article'
    options[:rate_limit] = 4
    options[:skip_patterns] = [
      /\Areference\//,
      /\Asamples\//,
      /\Aresources\//,
      /\Aabout\//,
      /\Asupport\//,
      /\Adownloads\//,
      /release-notes/,
      /\.(zip|json|txt|pdf)\z/
    ]

    # Links carry the reader's language and account (?hl=, ?authuser=).
    options[:fix_urls] = ->(url) do
      url.sub(/\?.*\z/, '')
    end

    options[:attribution] = <<-HTML
      &copy; Google LLC<br>
      Text licensed under the Creative Commons Attribution 4.0 License; code samples under the Apache License 2.0.
    HTML
  end
end
