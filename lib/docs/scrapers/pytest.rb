module Docs
  class Pytest < UrlScraper
    self.name = 'pytest'
    self.type = 'sphinx'
    self.release = '9.1.1'
    self.base_url = 'https://docs.pytest.org/en/stable/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://pytest.org/',
      code: 'https://github.com/pytest-dev/pytest'
    }

    # The navigation lives in the Furo sidebar, i.e. outside of the scraped
    # container, and the toctrees on the home page are hidden ones. The section
    # indexes, whose toctrees are part of the content, are used as entry points
    # instead.
    self.initial_paths = %w(
      getting-started.html
      how-to/index.html
      reference/index.html
      explanation/index.html
      example/index.html)

    html_filters.push 'pytest/clean_html', 'pytest/entries', 'sphinx/clean_html'

    options[:container] = 'article[role="main"] > section'

    # Restrict the scraper to the documentation itself, leaving out the project's
    # meta pages (changelog, contributing, sponsors, announcements, ...) and the
    # highlighted sources under _modules/.
    options[:only] = %w(index.html getting-started.html)
    options[:only_patterns] = [/\Ahow-to\//, /\Areference\//, /\Aexplanation\//, /\Aexample\//]

    options[:attribution] = <<-HTML
      &copy; 2015&ndash;2026 Holger Krekel and pytest-dev team<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('pytest-dev', 'pytest', opts)
    end
  end
end
