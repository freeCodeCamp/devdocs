module Docs
  class Matplotlib < UrlScraper
    include MultipleBaseUrls

    self.name = 'Matplotlib'
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'http://matplotlib.org/',
      code: 'https://github.com/matplotlib/matplotlib'
    }

    html_filters.push 'matplotlib/entries', 'sphinx/clean_html'

    options[:container] = '.body'
    options[:skip] = %w(api_changes.html tutorial.html faq.html)

    options[:attribution] = <<-HTML
      &copy; 2012&ndash;2016 Matplotlib Development Team. All rights reserved.<br>
      Licensed under the Matplotlib License Agreement.
    HTML

    version '1.5' do
      self.release = '1.5.1'
      self.base_urls = [
        'http://matplotlib.org/1.5.1/api/',
        'http://matplotlib.org/1.5.1/mpl_toolkits/mplot3d/',
        'http://matplotlib.org/1.5.1/mpl_toolkits/axes_grid/api/'
      ]
    end
  end
end
