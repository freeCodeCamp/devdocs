module Docs
  class Git < UrlScraper
    self.type = 'git'
    self.release = '2.42.0'
    self.base_url = 'https://git-scm.com/docs'
    self.initial_paths = %w(/git.html)
    self.links = {
      home: 'https://git-scm.com/',
      code: 'https://github.com/git/git'
    }

    html_filters.push 'git/entries', 'git/clean_html'

    options[:container] = '#content'
    options[:only_patterns] = [/\A\/[^\/]+\z/]
    options[:skip] = %w(/howto-index.html)

    options[:attribution] = <<-HTML
      &copy; 2012&ndash;2023 Scott Chacon and others<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://git-scm.com/', opts)
      doc.at_css('.version').content.strip
    end
  end
end
