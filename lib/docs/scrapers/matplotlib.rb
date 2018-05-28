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
      &copy; 2012&ndash;2017 Matplotlib Development Team. All rights reserved.<br>
      Licensed under the Matplotlib License Agreement.
    HTML

    version '2.1' do
      self.release = '2.1.0'
      self.base_urls = [
        "http://matplotlib.org/#{release}/api/",
        "http://matplotlib.org/#{release}/mpl_toolkits/mplot3d/",
        "http://matplotlib.org/#{release}/mpl_toolkits/axes_grid/api/"
      ]
    end

    version '2.0' do
      self.release = '2.0.2'
      self.base_urls = [
        "http://matplotlib.org/#{release}/api/",
        "http://matplotlib.org/#{release}/mpl_toolkits/mplot3d/",
        "http://matplotlib.org/#{release}/mpl_toolkits/axes_grid/api/"
      ]
    end

    version '1.5' do
      self.release = '1.5.3'
      self.base_urls = [
        "http://matplotlib.org/#{release}/api/",
        "http://matplotlib.org/#{release}/mpl_toolkits/mplot3d/",
        "http://matplotlib.org/#{release}/mpl_toolkits/axes_grid/api/"
      ]
    end
  end
end
