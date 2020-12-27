module Docs
  class Chef < UrlScraper
    self.type = 'sphinx_simple'
    self.base_url = 'https://docs.chef.io'
    self.links = {
      home: 'https://www.chef.io/',
      code: 'https://github.com/chef/chef'
    }

    options[:skip_patterns] = [
      /release_notes/,
      /feedback/
    ]

    options[:attribution] = <<-HTML
      &copy; Chef Software, Inc.<br>
      Licensed under the Creative Commons Attribution 3.0 Unported License.<br>
      The Chef&trade; Mark and Chef Logo are either registered trademarks/service marks or trademarks/service
      marks of Chef, in the United States and other countries and are used with Chef Inc's permission.<br>
      We are not affiliated with, endorsed or sponsored by Chef Inc.
    HTML

    version '16' do
      self.release = '16.8.14'

      options[:container] = '.off-canvas-wrapper'

      options[:skip] = [
        '/automate/api/',
        '/habitat/supervisor_api/',
        '/habitat/builder_api/'
      ]

      html_filters.push 'chef/entries', 'chef/clean_html'

    end

    version '12' do
      self.release = '12.13'
      self.base_url = 'https://docs-archive.chef.io/release/'

      html_filters.push 'chef/entries_old', 'chef/clean_html_old'

      options[:client_path] = client_path = '12-13'
      options[:server_path] = server_path = 'server_12-8'

      options[:skip_patterns] = [
        /\A[^\/]+\/\z/,
        /\A[^\/]+\/index\.html\z/,
        /\A[^\/]+\/release_notes\.html\z/,
        /\Aserver[^\/]+\/chef_overview\.html\z/,
        /\A[\d\-]+\/server_components\.html\z/
      ]

      self.root_path = "#{client_path}/chef_overview.html"
      self.initial_paths = ["#{server_path}/server_components.html"]

      options[:only_patterns] = [/\A#{client_path}\//, /\A#{server_path}\//]
    end

    version '11' do
      self.release = '11.18'
      self.base_url = 'https://docs-archive.chef.io/release/'

      html_filters.push 'chef/entries_old', 'chef/clean_html_old'

      options[:client_path] = client_path = '11-18'
      options[:server_path] = server_path = 'server_12-8'

      options[:skip_patterns] = [
        /\A[^\/]+\/\z/,
        /\A[^\/]+\/index\.html\z/,
        /\A[^\/]+\/release_notes\.html\z/,
        /\Aserver[^\/]+\/chef_overview\.html\z/,
        /\A[\d\-]+\/server_components\.html\z/
      ]

      self.root_path = "#{client_path}/chef_overview.html"
      self.initial_paths = ["#{server_path}/server_components.html"]

      options[:only_patterns] = [/\A#{client_path}\//, /\A#{server_path}\//]
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://downloads.chef.io/products/infra', opts)
      doc.at_css('#versions > option').content.strip
    end

  end
end
