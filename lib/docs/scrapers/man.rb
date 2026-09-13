module Docs
  class Man < FileScraper
    self.name = 'Linux man pages'
    self.type = 'simple'
    self.slug = 'man'
	  self.base_url = "https://man7.org/linux/man-pages/"
	  self.initial_paths = %w(dir_by_project.html)
    self.links = {
      home: 'https://man7.org/linux/man-pages/',
    }
    html_filters.push 'man/entries', 'man/clean_html'
    options[:attribution] = <<-HTML
	  ...
    HTML

    def get_latest_version(opts)
      body = fetch('https://man7.org/linux/man-pages/man7/man-pages.7.html', opts)
      body.match(/Linux man-pages ([\d.]+)/)[1]
    end
  end
end
