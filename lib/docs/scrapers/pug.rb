module Docs
  class Pug < UrlScraper
    self.type = 'pug'
    self.base_url = 'https://pugjs.org/'
    self.root_path = 'api/getting-started.html'
    self.release = '2.0.3'
    self.links = {
      home: 'https://pugjs.org/',
      code: 'https://github.com/pugjs/pug'
    }

    html_filters.push 'pug/clean_html', 'pug/entries'

    options[:container] = 'body > .container'

    options[:attribution] = <<-HTML
      &copy; Pug authors<br>
      Licensed under the MIT license.
    HTML

    def get_latest_version(opts)
      get_npm_version('pug', opts)
    end

    private

    def parse(response) # Hook here because Nokogori removes whitespace from textareas
      response.body.gsub! %r{<textarea\ [^>]*>([\W\w]+?)</textarea>}, '<pre>\1</pre>'
      super
    end
  end
end
