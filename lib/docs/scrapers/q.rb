module Docs
  class Q < Github
    self.name = 'Q'
    self.release = '1.5.1'
    self.base_url = 'https://github.com/kriskowal/q/wiki/'
    self.root_path = 'API-Reference'
    self.links = {
      home: 'http://documentup.com/kriskowal/q/',
      code: 'https://github.com/kriskowal/q'
    }

    html_filters.push 'q/entries', 'title'

    options[:container] = '.markdown-body'
    options[:title] = 'Q'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2009&ndash;2017 Kristopher Michael Kowal<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_npm_version('q', opts)
    end
  end
end
