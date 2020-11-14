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
      &copy; 2019 Docker, Inc.<br>
      Licensed under the Apache License, Version 2.0.<br>
      Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United States and/or other countries.<br>
      Docker, Inc. and other parties may also have trademark rights in other terms used herein.
    HTML

    version '19' do
      self.release = '19.03'
      self.base_url = "https://docs.docker.com/"

      html_filters.push 'docker/entries', 'docker/clean_html'

      options[:container] = '.wrapper .container-fluid .row'

      options[:only_patterns] = [/\Aget-started\//, /\Aengine\//, /\Acompose\//, /\Amachine\//, /\Anotary\//]
      options[:skip_patterns] = [/\Aengine\/api\/v/, /glossary/, /docker-ee/]

      options[:replace_paths] = {
        'install/linux/ubuntu/' => 'install/linux/docker-ce',
        'get-started/part1' => 'get-started',
        'engine/installation/' => 'install',
        'engine/installation/linux/linux-postinstall/' => 'install/linux',
        'compose/overview/' => 'compose',
        'docker-cloud/' => 'docker-hub',
        'datacenter/install/linux/' => 'ee',
        'engine/userguide/' => 'config/daemon',
        'engine/admin/' => 'config/daemon',
        'opensource/get-help/' => 'opensource',
        'engine/tutorials/dockerimages/' => 'get-started',
        'engine/admin/volumes/bind-mounts/' => 'storage',
        'engine/tutorials/dockervolumes/' => 'storage',
        'engine/admin/volumes/volumes/' => 'storage',
        'engine/userguide/labels-custom-metadata/' => 'config',
        'engine/userguide/eng-image/multistage-build/' => 'develop/develop-images',
        'engine/swarm/networking/' => 'network',
        'engine/admin/resource_constraints/' => 'config/containers',
        'engine/admin/logging/overview/' => 'config/containers/logging',
        'engine/userguide/eng-image/dockerfile_best-practices/' => 'develop/develop-images',
        'engine/tutorials/dockerrepos/' => 'get-started',
        'engine/userguide/networking/' => 'network',
        'engine/userguide/networking/get-started-overlay/' => 'network',
        'engine/reference/commandline/swarm_join_token/' => 'engine/reference/commandline',
        'engine/understanding-docker/' => 'engine',
        'engine/userguide/dockervolumes/' => 'storage',
        'engine/installation/binaries/' => 'install/linux/docker-ce',
        'engine/userguide/networking/default_network/dockerlinks/' => 'network',
        'engine/reference/api/' => 'develop/sdk',
        'engine/admin/systemd/' => 'config/daemon',
        'engine/userguide/storagedriver/imagesandcontainers/' => 'storage/storagedriver',
        'engine/api/' => 'develop/sdk',
        'engine/userguide/networking/get-started-overlay' => 'network',
        'engine/userguide/networking/overlay-security-model/' => 'network',
        'engine/installation/linux/docker-ce/binaries/' => 'install/linux/docker-ce',
        'engine/admin/volumes/' => 'storage/volumes/',
        'engine/userguide/networking//' => 'network',
        'engine/reference/commandline' => 'engine/reference/commandline/docker',
        'engine/reference/commandline/' => 'engine/reference/commandline/docker/',
      }
    end

    version '18' do
      self.release = '18.09'
      self.base_url = "https://docs.docker.com/v#{release}/"

      html_filters.push 'docker/entries', 'docker/clean_html'

      options[:container] = '.wrapper .container-fluid .row'

      options[:only_patterns] = [/\Aget-started\//, /\Aengine\//, /\Acompose\//, /\Amachine\//, /\Anotary\//]
      options[:skip_patterns] = [/\Aengine\/api\/v/, /glossary/, /docker-ee/]

      options[:replace_paths] = {
        'install/linux/ubuntu/' => 'install/linux/docker-ce',
        'get-started/part1' => 'get-started',
        'engine/installation/' => 'install',
        'engine/installation/linux/linux-postinstall/' => 'install/linux',
        'compose/overview/' => 'compose',
        'datacenter/install/linux/' => 'ee',
        'engine/userguide/' => 'config/daemon',
        'engine/admin/' => 'config/daemon',
        'opensource/get-help/' => 'opensource',
        'engine/tutorials/dockerimages/' => 'get-started',
        'engine/admin/volumes/bind-mounts/' => 'storage',
        'engine/tutorials/dockervolumes/' => 'storage',
        'engine/admin/volumes/volumes/' => 'storage',
        'engine/userguide/labels-custom-metadata/' => 'config',
        'engine/reference/api/' => 'develop/sdk',
        'engine/userguide/eng-image/multistage-build/' => 'develop/develop-images',
        'engine/swarm/networking/' => 'network',
        'engine/admin/resource_constraints/' => 'config/containers',
        'engine/admin/logging/overview/' => 'config/containers/logging',
        'engine/userguide/eng-image/dockerfile_best-practices/' => 'develop/develop-images',
        'engine/tutorials/dockerrepos/' => 'get-started',
        'engine/userguide/networking/' => 'network',
        'engine/userguide/networking/get-started-overlay/' => 'network',
        'engine/understanding-docker/' => 'engine',
        'engine/reference/commandline/swarm_join_token/' => 'engine/reference/commandline',
        'engine/userguide/dockervolumes/' => 'storage',
        'engine/admin/systemd/' => 'config/daemon',
        'engine/userguide/storagedriver/imagesandcontainers/' => 'storage/storagedriver',
        'engine/installation/binaries/' => 'install/linux/docker-ce',
        'engine/userguide/networking/default_network/dockerlinks/' => 'network',
        'engine/userguide/networking/overlay-security-model/' => 'network',
        'engine/userguide/networking/get-started-overlay' => 'network',
        'engine/api/' => 'develop/sdk',
        'engine/installation/linux/docker-ce/binaries/' => 'install/linux/docker-ce',
        'engine/admin/volumes/' => 'storage/volumes/',
        'engine/userguide/networking//' => 'network',
        'engine/reference/commandline' => 'engine/reference/commandline/docker',
        'engine/reference/commandline/' => 'engine/reference/commandline/docker/',
      }
    end

    version '17' do
      self.release = '17.12'
      self.base_url = "https://docs.docker.com/v#{release}/"

      html_filters.push 'docker/entries', 'docker/clean_html'

      options[:container] = '.wrapper .container-fluid .row'

      options[:only_patterns] = [/\Aget-started\//, /\Aengine\//, /\Acompose\//, /\Amachine\//, /\Anotary\//]
      options[:skip_patterns] = [/\Aengine\/api\/v/, /glossary/, /docker-ee/]

      options[:replace_paths] = {
        'get-started/part1' => 'get-started',
        'engine/installation/' => 'install',
        'engine/installation/linux/linux-postinstall/' => 'install/linux',
        'opensource/get-help/' => 'opensource',
        'engine/admin/volumes/volumes/' => 'storage',
        'engine/tutorials/dockerimages/' => 'get-started',
        'engine/admin/volumes/bind-mounts/' => 'storage',
        'engine/tutorials/dockervolumes/' => 'storage',
        'datacenter/install/aws/' => 'docker-for-aws',
        'engine/userguide/' => 'config/daemon',
        'engine/admin/' => 'config/daemon',
        'engine/userguide/labels-custom-metadata/' => 'config',
        'engine/userguide/eng-image/multistage-build/' => 'develop/develop-images',
        'engine/swarm/networking/' => 'network',
        'engine/admin/resource_constraints/' => 'config/containers',
        'engine/admin/logging/overview/' => 'config/containers/logging',
        'engine/understanding-docker/' => 'engine',
        'engine/userguide/eng-image/dockerfile_best-practices/' => 'develop/develop-images',
        'engine/tutorials/dockerrepos/' => 'get-started',
        'engine/userguide/networking/' => 'network',
        'engine/reference/commandline/swarm_join_token/' => 'edge/engine/reference/commandline',
        'engine/userguide/networking/get-started-overlay/' => 'network',
        'engine/userguide/dockervolumes/' => 'storage',
        'engine/installation/binaries/' => 'install/linux/docker-ce',
        'engine/userguide/networking/default_network/dockerlinks/' => 'network',
        'engine/reference/api/' => 'develop/sdk',
        'engine/admin/live-restore/' => 'config/containers',
        'engine/api/' => 'develop/sdk',
        'engine/userguide/networking/get-started-overlay' => 'network',
        'security/security/' => 'engine/security',
        'engine/installation/linux/docker-ce/binaries/' => 'install/linux/docker-ce',
        'engine/reference/commandline/' => 'edge/engine/reference/commandline',
        'engine/admin/systemd/' => 'config/daemon',
        'engine/userguide/storagedriver/imagesandcontainers/' => 'storage/storagedriver',
        'engine/userguide/networking/overlay-security-model/' => 'network',
        'engine/admin/volumes/' => 'storage/volumes/',
        'engine/userguide/networking//' => 'network',
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

    def get_latest_version(opts)
      doc = fetch_doc('https://docs.docker.com/engine/release-notes/', opts)
      latest_version = doc.at_css('.content > section > h1[id^="version-"]').content.strip
      latest_version.rpartition(' ')[-1]
    end
  end
end
