module Docs
  class Docker < UrlScraper
    self.type = 'docker'
    self.links = {
      home: 'https://docker.com/',
      code: 'https://github.com/docker/docker'
    }

    html_filters.push 'docker/entries', 'docker/clean_html'

    options[:container] = '#docs'
    options[:trailing_slash] = true

    options[:only_patterns] = [
      /\Aengine\//,
      /\Acompose\//,
      /\Amachine\//,
      /\Aswarm\//
    ]
    options[:skip] = %w(swarm/scheduler/)
    options[:replace_paths] = {
      'engine/installation/ubuntulinux/' => 'engine/installation/linux/ubuntulinux/'
    }

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2016 Docker, Inc.<br>
      Licensed under the Apache License, Version 2.0.<br>
      Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries.<br>
      Docker, Inc. and other parties may also have trademark rights in other terms used herein.
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
