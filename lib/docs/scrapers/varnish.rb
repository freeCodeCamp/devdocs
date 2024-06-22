module Docs
  class Varnish < UrlScraper
    self.name = 'Varnish'
    self.type = 'sphinx'

    self.root_path = 'index.html'
    self.links = {
      home: 'https://varnish-cache.org/',
      code: 'https://github.com/varnishcache/varnish-cache'
    }

    html_filters.push 'varnish/entries', 'sphinx/clean_html'

    options[:container] = '.body > section'
    options[:skip] = %w(genindex.html search.html)
    options[:skip_patterns] = [/phk/, /glossary/, /whats-new/]

    options[:attribution] = <<-HTML
      Copyright &copy; 2006 Verdens Gang AS<br>
      Copyright &copy; 2006&ndash;2020 Varnish Software AS<br>
      Licensed under the BSD-2-Clause License.
    HTML

    version do
      self.release = '7.4'
      self.base_url = "https://varnish-cache.org/docs/#{release}/"
    end

    def get_latest_version(opts)
      contents = get_github_file_contents('varnishcache', 'varnish-cache', 'doc/changes.rst', opts)
      contents.scan(/Varnish\s+Cache\s+([0-9.]+)/)[0][0]
    end

  end
end
