module Docs
  class Rack < Rdoc

    self.name = 'Ruby / Rack'
    self.slug = 'rack'
    self.release = '3.2.4'
    self.links = {
      home: 'https://rack.github.io/rack/3.2/index.html',
      code: 'https://github.com/rack/rack'
    }
    self.root_path = 'Rack.html'

    options[:root_title] = 'Rack'

    options[:attribution] = <<-HTML
      &copy; 2007-2021 Leah Neukirchen<br>
      Licensed under the MIT License.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('rack', 'rack', opts)
    end
  end
end
