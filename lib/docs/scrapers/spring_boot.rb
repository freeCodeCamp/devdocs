module Docs
  class SpringBoot < UrlScraper
    self.name = 'Spring Boot'
    self.slug = 'spring_boot'
    self.type = 'simple'
    self.release = '2.3.0.RELEASE'
    self.base_url = 'https://docs.spring.io/spring-boot/docs/current/reference/html/'
    self.root_path = "index.html"
    self.links = {
      home: 'https://spring.io/',
      code: 'https://github.com/spring-projects/spring-boot'
    }

    html_filters.push 'spring_boot/entries', 'spring_boot/clean_html'

    options[:skip_patterns] = [/legal/]

    options[:attribution] = <<-HTML
    Copyright &copy; 2002 - 2020 Pivotal, Inc. All Rights Reserved.
    HTML

    def get_latest_version(opts)
      doc = fetch_doc('https://docs.spring.io/spring-boot/docs/current/reference/html/legal.html', opts)
      table = doc.at_css('#content p').inner_text
    end

  end
end
