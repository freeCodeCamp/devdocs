module Docs
  class Angular < UrlScraper
    # This scraper is currently broken; the problem being that Angular's
    # documentation isn't available as static pages. I will try to restore it
    # once Angular 1.2.0 is released.
    #
    # In the past it used static-ng-doc by Sal Lara (github.com/natchiketa/static-ng-doc)
    # to scrape the doc's HTML partials (e.g. docs.angularjs.org/partials/api/ng.html).
    #
    # If you want to help this is what I need: a static page with links to each
    # HTML partial. Or better yet, a static version of Angular's documentation.

    self.name = 'Angular.js'
    self.slug = 'angular'
    self.type = 'angular'
    self.version = '1.0.7'
    self.base_url = ''
    self.language = 'javascript'
  end
end
