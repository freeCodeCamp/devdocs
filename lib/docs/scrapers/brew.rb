module Docs
  class Brew < UrlScraper
    self.name = 'Homebrew'
    self.type = 'brew'
    self.release = '1.3.6'
    self.base_url = 'https://docs.brew.sh'
    self.root_path = '/'
    self.links = {
      home: 'https://brew.sh',
      code: 'https://github.com/Homebrew/brew'
    }

    options[:container] = ->(filter) { filter.root_page? ? '#home' : '#page' }    

    html_filters.push 'brew/entries', 'brew/clean_html'

    options[:attribution] = <<-HTML
      Homebrew was created by Max Howell. <br>
      Licensed under the BSD 2-Clause License.
    HTML
  end
end
