module Docs
  class Docker < UrlScraper
    self.type = 'simple'
    self.links = {
      home: 'https://docker.com/',
      code: 'https://github.com/docker/docker'
    }

    options[:trailing_slash] = true

    options[:fix_urls] = ->(url) do
      url.sub! %r{\.md/?(?=#|\z)}, '/'
      url.sub! '/index/', '/'
      url
    end

    options[:attribution] = <<-HTML
      &copy; 2017 Docker, Inc.<br>
      Licensed under the Apache License, Version 2.0.<br>
      Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries.<br>
      Docker, Inc. and other parties may also have trademark rights in other terms used herein.
    HTML

    version '17' do
      self.release = '17.06'
      self.base_url = 'https://docs.docker.com/'

      html_filters.push 'docker/entries', 'docker/clean_html'

      options[:container] = '.wrapper .container-fluid .row'

      options[:only_patterns] = [/\Aget-started\//, /\Aengine\//, /\Acompose\//, /\Amachine\//, /\Anotary\//]
      options[:skip_patterns] = [/\Aengine\/api\/v/, /glossary/, /docker-ee/]

      options[:replace_paths] = {
        'engine/installation/linux/docker-ee/linux-postinstall/' => 'engine/installation/linux/linux-postinstall/',
        'engine/installation/linux/docker-ee/' => 'engine/installation/',
        'engine/installation/linux/docker-ce/' => 'engine/installation/',
        'engine/installation/linux/' => 'engine/installation/',
        'engine/installation/windows/' => 'engine/installation/',
        'engine/userguide/intro/' => 'engine/userguide/',
        'engine/tutorials/dockervolumes/' => 'engine/admin/volumes/volumes/',
        'engine/getstarted/' => 'get-started/',
        'engine/tutorials/dockerimages/' => 'get-started/',
        'engine/tutorials/dockerrepos/' => 'get-started/',
        'engine/admin/host_integration/' => 'engine/admin/start-containers-automatically/',
        'engine/installation/linux/rhel/' => 'engine/installation/linux/docker-ee/rhel/',
        'engine/installation/linux/ubuntulinux/' => 'engine/installation/linux/docker-ee/ubuntu/',
        'engine/installation/linux/suse/' => 'engine/installation/linux/docker-ee/suse/',
        'engine/admin/logging/' => 'engine/admin/logging/view_container_logs/',
        'engine/swarm/how-swarm-mode-works/' => 'engine/swarm/how-swarm-mode-works/nodes/',
        'engine/installation/binaries/' => 'engine/installation/linux/docker-ce/binaries/',
        'engine/reference/commandline/' => 'engine/reference/commandline/docker/',
        'engine/reference/api/' => 'engine/api/',
        'engine/userguide/dockervolumes/' => 'engine/admin/volumes/volumes/',
        'engine/understanding-docker/' => 'engine/docker-overview/',
        'engine/reference/commandline/swarm_join_token/' => 'engine/reference/commandline/swarm_join-token/',
        'engine/api/getting-started/' => 'engine/api/get-started/',
      }
    end

    module OldOptions
      def self.included(klass)
        klass.options[:only_patterns] = [/\Aengine\//, /\Acompose\//, /\Amachine\//]
        klass.options[:skip_patterns] = [/\Aengine\/api\/v/, /\Aengine\/installation/]
        klass.options[:skip] = %w(
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
        klass.options[:replace_paths] = {
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
      end
    end

    version '1.13' do
      include OldOptions

      self.release = '1.13'
      self.base_url = "https://docs.docker.com/v#{self.version}/"

      html_filters.push 'docker/entries_old', 'docker/clean_html_old'

      options[:container] = '.container-fluid .row'
    end

    version '1.12' do
      include OldOptions

      self.release = '1.12'
      self.base_url = "https://docs.docker.com/v#{self.version}/"

      html_filters.push 'docker/entries_old', 'docker/clean_html_old'

      options[:container] = '.container-fluid .row'
    end

    version '1.11' do
      include OldOptions

      self.release = '1.11'
      self.base_url = "https://docs.docker.com/v#{self.version}/"

      html_filters.push 'docker/entries_very_old', 'docker/clean_html_very_old'

      options[:container] = '#docs'
      options[:only_patterns] << /\Aswarm\//
    end

    version '1.10' do
      include OldOptions

      self.release = '1.10'
      self.base_url = "https://docs.docker.com/v#{self.version}/"

      html_filters.push 'docker/entries_very_old', 'docker/clean_html_very_old'

      options[:container] = '#docs'
      options[:only_patterns] << /\Aswarm\//
    end
  end
end
