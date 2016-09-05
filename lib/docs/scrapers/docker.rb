module Docs
  class Docker < UrlScraper
    self.type = 'docker'
    self.links = {
      home: 'https://docker.com/',
      code: 'https://github.com/docker/docker'
    }

    options[:trailing_slash] = true

    options[:only_patterns] = [/\Aengine\//, /\Acompose\//, /\Amachine\//]

    options[:skip] = %w(
      swarm/scheduler/
      swarm/swarm_at_scale/
      swarm/reference/
      engine/installation/linux/
      engine/installation/cloud/
      engine/installation/
      engine/tutorials/
      engine/userguide/
      engine/extend/
      engine/examples/
      engine/reference/
      engine/reference/api/
      engine/security/
      engine/security/trust/
      engine/getstarted/linux_install_help/
      machine/reference/
      machine/drivers/
      machine/examples/
      compose/reference/
    ) # index pages

    options[:replace_paths] = {
      'engine/installation/ubuntulinux/'            => 'engine/installation/linux/ubuntulinux/',
      'engine/userguide/networking/dockernetworks/' => 'engine/userguide/networking/',
      'engine/reference/logging/overview/'          => 'engine/admin/logging/overview/',
      'engine/userguide/dockervolumes/'             => 'engine/tutorials/dockervolumes/'
    }

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2016 Docker, Inc.<br>
      Licensed under the Apache License, Version 2.0.<br>
      Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries.<br>
      Docker, Inc. and other parties may also have trademark rights in other terms used herein.
    HTML

    version '1.12' do
      self.release = '1.12'
      self.base_url = 'https://docs.docker.com/'

      html_filters.push 'docker/entries', 'docker/clean_html'

      options[:container] = '.container-fluid .row'
    end

    version '1.11' do
      self.release = '1.11'
      self.base_url = "https://docs.docker.com/v#{self.version}/"

      html_filters.push 'docker/entries_old', 'docker/clean_html_old'

      options[:container] = '#docs'
      options[:only_patterns] << /\Aswarm\//
    end

    version '1.10' do
      self.release = '1.10'
      self.base_url = "https://docs.docker.com/v#{self.version}/"

      html_filters.push 'docker/entries_old', 'docker/clean_html_old'

      options[:container] = '#docs'
      options[:only_patterns] << /\Aswarm\//
    end
  end
end
