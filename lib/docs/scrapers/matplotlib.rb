module Docs
  class Matplotlib < UrlScraper
    self.name = 'Matplotlib'
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'http://matplotlib.org/',
      code: 'https://github.com/matplotlib/matplotlib'
    }

    html_filters.push 'matplotlib/entries', 'sphinx/clean_html'

    options[:container] = '.body'
    options[:skip] = %w(api_changes.html)

    options[:attribution] = <<-HTML
      &copy; 2012&ndash;2016 Matplotlib Development Team. All rights reserved.<br>
      Licensed under the Matplotlib License Agreement.
    HTML

    version '1.5' do
      self.release = '1.5.1'
      self.base_url = 'http://matplotlib.org/1.5.1/api/'
    end
  end
end
