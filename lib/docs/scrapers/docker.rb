module Docs
  class Docker < UrlScraper
    include MultipleBaseUrls

    self.name = 'Docker'
    self.type = 'simple'

    self.links = {
      home: 'https://docker.com/',
      code: 'https://github.com/docker/docker'
    }

    html_filters.push 'docker/entries', 'docker/clean_html'

    options[:only_patterns] = [/\Aget-started\//, /\Aengine\//, /\Acompose\//, /\Amachine\//, /\Anotary\//]

    options[:skip_patterns] = [/\Aengine\/api\/v/, /glossary/, /docker-ee/]

    options[:skip] = [
      'engine/userguide/networking/get-started-overlay/'
    ]

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

    options[:replace_paths] = {
      'engine/userguide/' => 'config/daemon',
      'engine/userguide/labels-custom-metadata/' => 'config',
      'engine/swarm/networking/' => 'network/overlay',
      'engine/userguide/eng-image/dockerfile_best-practices/' => 'develop/develop-images/dockerfile_best-practices/',
      'engine/userguide/networking/get-started-overlay/' => 'network/network-tutorial-overlay/',
      'engine/userguide/networking/' => 'network/',
      'engine/reference/api/' => 'develop/sdk',
      'engine/api/latest/' => 'develop/sdk',
      'get-started/part3/' => 'get-started/04_sharing_app/',
      'engine/security/https/' => 'engine/security/protect-access/',
      'compose/aspnet-mssql-compose/' => 'samples/aspnet-mssql-compose/',
      'engine/examples/dotnetcore/' => 'samples/dotnetcore/'
    }

    version do
      self.release = '20.10.16'
      self.base_url = "https://docs.docker.com"
      self.base_urls = [
        'https://docs.docker.com/',
        'https://docs.docker.com/machine/'
      ]
    end

    version '19' do
      self.release = '19.03'
      self.base_url = "https://docs.docker.com"
    end

    version '18' do
      self.release = '18.09'
      self.base_url = "https://docs.docker.com"
    end

    version '17' do
      self.release = '17.12'
      self.base_url = "https://docs.docker.com"
    end

    version '1.13' do
      self.release = '1.13'
      self.base_url = "https://docs.docker.com"
    end

    version '1.12' do
      self.release = '1.12'
      self.base_url = "https://docs.docker.com"
    end

    version '1.11' do
      self.release = '1.11'
      self.base_url = "https://docs.docker.com"
    end

    version '1.10' do
      self.release = '1.10'
      self.base_url = "https://docs.docker.com"
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://docs.docker.com/engine/release-notes/', opts)
      latest_version = doc.at_css('.content > section > h2').content.strip
      latest_version.rpartition(' ')[-1]
    end
  end
end
