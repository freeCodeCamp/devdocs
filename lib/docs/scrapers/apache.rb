module Docs
  class Apache < UrlScraper
    self.name = 'Apache HTTP Server'
    self.slug = 'apache_http_server'
    self.type = 'apache'
    self.release = '2.4.34'
    self.base_url = 'https://httpd.apache.org/docs/2.4/en/'
    self.links = {
      home: 'https://httpd.apache.org/'
    }

    html_filters.push 'apache/clean_html', 'apache/entries'

    options[:container] = '#page-content'

    options[:skip] = %w(
      upgrading.html
      license.html
      sitemap.html
      glossary.html
      mod/quickreference.html
      mod/directive-dict.html
      mod/directives.html
      mod/module-dict.html
      programs/other.html)

    options[:skip_patterns] = [
      /\A(da|de|en|es|fr|ja|ko|pt-br|tr|zh-cn)\//,
      /\Anew_features/,
      /\Adeveloper\// ]

    options[:attribution] = <<-HTML
      &copy; 2018 The Apache Software Foundation<br>
      Licensed under the Apache License, Version 2.0.
    HTML
  end
end
