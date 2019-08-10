module Docs
  class Matplotlib < UrlScraper
    include MultipleBaseUrls

    self.name = 'Matplotlib'
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://matplotlib.org/',
      code: 'https://github.com/matplotlib/matplotlib'
    }

    html_filters.push 'matplotlib/entries', 'sphinx/clean_html'

    options[:container] = '.body'
    options[:skip] = %w(api_changes.html tutorial.html faq.html)

    options[:attribution] = <<-HTML
      &copy; 2012&ndash;2018 Matplotlib Development Team. All rights reserved.<br>
      Licensed under the Matplotlib License Agreement.
    HTML

    version '3.1' do
      self.release = '3.1.1'
      self.base_urls = [
        "https://matplotlib.org/#{release}/api/",
        "https://matplotlib.org/#{release}/mpl_toolkits/mplot3d/",
        "https://matplotlib.org/#{release}/mpl_toolkits/axes_grid/api/"
      ]
    end

    version '3.0' do
      self.release = '3.0.0'
      self.base_urls = [
        "https://matplotlib.org/#{release}/api/",
        "https://matplotlib.org/#{release}/mpl_toolkits/mplot3d/",
        "https://matplotlib.org/#{release}/mpl_toolkits/axes_grid/api/"
      ]
    end

    version '2.2' do
      self.release = '2.2.3'
      self.base_urls = [
        "https://matplotlib.org/#{release}/api/",
        "https://matplotlib.org/#{release}/mpl_toolkits/mplot3d/",
        "https://matplotlib.org/#{release}/mpl_toolkits/axes_grid/api/"
      ]
    end

    version '2.1' do
      self.release = '2.1.0'
      self.base_urls = [
        "https://matplotlib.org/#{release}/api/",
        "https://matplotlib.org/#{release}/mpl_toolkits/mplot3d/",
        "https://matplotlib.org/#{release}/mpl_toolkits/axes_grid/api/"
      ]
    end

    version '2.0' do
      self.release = '2.0.2'
      self.base_urls = [
        "https://matplotlib.org/#{release}/api/",
        "https://matplotlib.org/#{release}/mpl_toolkits/mplot3d/",
        "https://matplotlib.org/#{release}/mpl_toolkits/axes_grid/api/"
      ]
    end

    version '1.5' do
      self.release = '1.5.3'
      self.base_urls = [
        "https://matplotlib.org/#{release}/api/",
        "https://matplotlib.org/#{release}/mpl_toolkits/mplot3d/",
        "https://matplotlib.org/#{release}/mpl_toolkits/axes_grid/api/"
      ]
    end

    def get_latest_version(opts)
      get_latest_github_release('matplotlib', 'matplotlib', opts)
    end
  end
end
