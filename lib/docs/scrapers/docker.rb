module Docs
  class Docker < UrlScraper
    self.name = 'Docker'
    self.slug = 'docker'
    self.type = 'docker'

    self.links = {
      home: 'https://docker.com/',
      code: 'https://github.com/docker/docker'
    }

    html_filters.push 'docker/clean_html', 'docker/entries'

    options[:trailing_slash] = true

    options[:only_patterns] = [
      /\Aengine\//,
      /\Acompose\//,
      /\Amachine\//,
      /\Aswarm\//
    ]

    options[:skip] = [
      "engine/installation/ubuntulinux/" # invalid document
    ]

    options[:attribution] = <<-HTML
      &copy; 2016 Docker Inc.<br>
      Licensed under the Apache 2 License.
    HTML

    version '1.11' do
      self.release = '1.11'
      self.base_url = "https://docs.docker.com/v#{self.version}/"
    end

    version '1.10' do
      self.release = '1.10'
      self.base_url = "https://docs.docker.com/v#{self.version}/"
    end
  end
end
