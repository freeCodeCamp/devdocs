module Docs
  class Bluebird < UrlScraper
    self.name = 'Bluebird'
    self.type = 'bluebird'
    self.version = '3.0'
    self.base_url = 'http://bluebirdjs.com/docs/'
    self.root_path = '/api-reference.html'
    self.initial_paths = [
      '/api-reference.html'
    ]
    self.links = {
      home: 'http://bluebirdjs.com',
      code: 'http://github.com/petkaantanov/bluebird'
    }

    html_filters.push 'bluebird/clean_html', 'bluebird/entries'

    options[:container] = '.post'

    options[:skip] = %w(
      anti-patterns.html
      beginners-guide.html
      warning-explanations.html
      contribute.html
      benchmarks.html
      deprecated-apis.html
      changelog.html
      features.html
      why-performance.html
      what-about-generators.html
      async-dialogs.html
      support.html
      install.html)

    options[:attribution] = <<-HTML
      Written by @petkaantanov and contributors
    HTML
  end
end
