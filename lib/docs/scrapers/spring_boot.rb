module Docs
  class SpringBoot < UrlScraper
    self.name = 'Spring Boot'
    self.slug = 'spring_boot'
    self.type = 'simple'
    self.root_path = "index.html"
    self.links = {
      home: 'https://spring.io/',
      code: 'https://github.com/spring-projects/spring-boot'
    }

    html_filters.push 'spring_boot/entries', 'spring_boot/clean_html'

    options[:skip_patterns] = [/legal/]

    options[:attribution] = <<-HTML
    Copyright &copy; 2002–2020 Pivotal, Inc. All Rights Reserved.
    HTML

    version do
      self.release = '2.4.0'
      self.base_url = "https://docs.spring.io/spring-boot/docs/#{release}/reference/html/"
    end

    def get_latest_version(opts)
      get_latest_github_release('spring-projects', 'spring-boot', opts)
    end

  end
end
