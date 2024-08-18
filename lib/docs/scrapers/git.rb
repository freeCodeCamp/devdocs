module Docs
  class Git < UrlScraper
    self.type = 'git'
    self.release = '2.46.0'
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

    # https://github.com/git/git?tab=License-1-ov-file#readme
    # NOT https://github.com/git/git-scm.com/blob/main/MIT-LICENSE.txt
    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2024 Linus Torvalds and others<br>
      Licensed under the GNU General Public License version 2.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://git-scm.com/', opts)
      doc.at_css('.version').content.strip
    end
  end
end
