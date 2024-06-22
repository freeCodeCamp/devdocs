module Docs
  class Knockout < UrlScraper
    self.name = 'Knockout.js'
    self.slug = 'knockout'
    self.type = 'knockout'
    self.release = '3.5.1'
    self.base_url = 'https://knockoutjs.com/documentation/'
    self.root_path = 'introduction.html'
    self.links = {
      home: 'https://knockoutjs.com/',
      code: 'https://github.com/knockout/knockout'
    }

    html_filters.push 'knockout/clean_html', 'knockout/entries'

    options[:follow_links] = ->(filter) { filter.root_page? }
    options[:container] = ->(filter) { filter.root_page? ? '#wrapper' : '.content' }

    options[:only] = %w(
      json-data.html
      extenders.html
      deferred-updates.html
      unobtrusive-event-handling.html
      fn.html
      microtasks.html
      asynchronous-error-handling.html
      amd-loading.html)

    options[:only_patterns] = [
      /observable/i,
      /computed/i,
      /component/i,
      /binding/,
      /plugin/]

    options[:attribution] = <<-HTML
      &copy; Steven Sanderson, the Knockout.js team, and other contributors<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('knockout', 'knockout', opts)
    end
  end
end
