module Docs
  class Reactivex < UrlScraper
    self.type = 'reactivex'
    self.name = 'ReactiveX'
    self.base_url = 'http://reactivex.io/'
    self.root_path = 'intro.html'
    self.links = {
      home: 'http://reactivex.io/'
    }

    html_filters.push 'reactivex/entries', 'reactivex/clean_html'

    options[:download_images] = false

    options[:only_patterns] = [/documentation\//]
    options[:skip_patterns] = [/ko\//]

    options[:attribution] = <<-HTML
      &copy; ReactiveX contributors<br>
      Licensed under the Apache License 2.0.
    HTML
  end
end
