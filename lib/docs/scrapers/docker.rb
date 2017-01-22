module Docs
  class Docker < UrlScraper
    self.type = 'docker'
    self.links = {
      home: 'https://docker.com/',
      code: 'https://github.com/docker/docker'
    }

    options[:trailing_slash] = true

    options[:only_patterns] = [/\Aengine\//, /\Acompose\//, /\Amachine\//]
    options[:skip_patterns] = [/\Aengine\/api\/v/, /\Aengine\/installation/]
    options[:skip] = %w(
      /
      engine/userguide/
      engine/examples/
      engine/reference/
      engine/reference/api/
      engine/reference/api/docker_remote_api_v1.24/
      engine/getstarted/linux_install_help/
      machine/reference/
      machine/drivers/
      machine/examples/
      compose/reference/
    )

    options[:fix_urls] = ->(url) do
      url.sub! %r{\.md/?(?=#|\z)}, '/'
      url.sub! '/index/', '/'
      url
    end

    options[:replace_paths] = {
      'engine/userguide/networking/dockernetworks/' => 'engine/userguide/networking/',
      'engine/userguide/dockervolumes/'             => 'engine/tutorials/dockervolumes/',
      'engine/reference/logging/overview/'          => 'engine/admin/logging/overview/',
      'engine/reference/commandline/daemon/'        => 'engine/reference/commandline/dockerd/',
      'engine/reference/commandline/'               => 'engine/reference/commandline/docker/',
      'engine/reference/api/docker_remote_api/'     => 'engine/api/',
      'engine/swarm/how-swarm-mode-works/'          => 'engine/swarm/how-swarm-mode-works/nodes/',
      'engine/tutorials/dockerizing/'               => 'engine/getstarted/step_one/',
      'engine/tutorials/usingdocker/'               => 'engine/getstarted/step_three/',
      'engine/tutorials/dockerimages/'              => 'engine/getstarted/step_four/',
      'engine/tutorials/dockerrepos/'               => 'engine/getstarted/step_six/'
    }

    options[:attribution] = <<-HTML
      &copy; 2013&ndash;2016 Docker, Inc.<br>
      Licensed under the Apache License, Version 2.0.<br>
      Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries.<br>
      Docker, Inc. and other parties may also have trademark rights in other terms used herein.
    HTML

    version '1.13' do
      self.release = '1.13'
      self.base_url = 'https://docs.docker.com/'

      html_filters.push 'docker/entries', 'docker/clean_html'

      options[:container] = '.container-fluid .row'
    end

    version '1.12' do
      self.release = '1.12'
      # self.base_url = 'https://docs.docker.com/'

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
