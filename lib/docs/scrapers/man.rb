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
  end
end
