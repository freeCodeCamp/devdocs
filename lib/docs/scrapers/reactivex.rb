module Docs
  class Reactivex < UrlScraper
    self.name = 'ReactiveX'
    self.type = 'reactivex'
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

    def get_latest_version(opts)
      get_latest_github_commit_date('ReactiveX', 'reactivex.github.io', opts)
    end
  end
end
