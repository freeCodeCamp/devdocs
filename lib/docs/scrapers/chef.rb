module Docs
  class Chef < UrlScraper
    self.type = 'sphinx_simple'
    self.base_url = 'https://docs-archive.chef.io/release/'
    self.links = {
      home: 'https://www.chef.io/',
      code: 'https://github.com/chef/chef'
    }

    html_filters.push 'chef/entries', 'chef/clean_html'

    options[:skip_patterns] = [
      /\A[^\/]+\/\z/,
      /\A[^\/]+\/index\.html\z/,
      /\A[^\/]+\/release_notes\.html\z/,
      /\Aserver[^\/]+\/chef_overview\.html\z/,
      /\A[\d\-]+\/server_components\.html\z/ ]

    options[:attribution] = <<-HTML
      &copy; Chef Software, Inc.<br>
      Licensed under the Creative Commons Attribution 3.0 Unported License.<br>
      The Chef&trade; Mark and Chef Logo are either registered trademarks/service marks or trademarks/service
      marks of Chef, in the United States and other countries and are used with Chef Inc's permission.<br>
      We are not affiliated with, endorsed or sponsored by Chef Inc.
    HTML

    version '12' do
      self.release = '12.13'

      options[:client_path] = client_path = '12-13'
      options[:server_path] = server_path = 'server_12-8'

      self.root_path = "#{client_path}/chef_overview.html"
      self.initial_paths = ["#{server_path}/server_components.html"]

      options[:only_patterns] = [/\A#{client_path}\//, /\A#{server_path}\//]
    end

    version '11' do
      self.release = '11.18'

      options[:client_path] = client_path = '11-18'
      options[:server_path] = server_path = 'server_12-8'

      self.root_path = "#{client_path}/chef_overview.html"
      self.initial_paths = ["#{server_path}/server_components.html"]

      options[:only_patterns] = [/\A#{client_path}\//, /\A#{server_path}\//]
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://downloads.chef.io/chef', opts)
      doc.at_css('h1.product-heading > span').content.strip
    end
  end
end
