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

    # https://github.com/spring-projects/spring-boot/blob/main/buildSrc/src/main/resources/NOTICE.txt
    options[:attribution] = <<-HTML
    Copyright &copy; 2012-2023 VMware, Inc.<br>
    Licensed under the Apache License, Version 2.0.
    HTML

    self.release = '3.1.3'
    self.base_url = "https://docs.spring.io/spring-boot/docs/#{release}/reference/html/"

    def get_latest_version(opts)
      get_latest_github_release('spring-projects', 'spring-boot', opts)
    end

  end
end
