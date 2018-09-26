module Docs
  class SaltStack < UrlScraper
    self.type = 'salt_stack'
    self.release = '2018.3.2'
    self.base_url = 'https://docs.saltstack.com/en/latest/ref/'

    html_filters.push 'salt_stack/clean_html', 'salt_stack/entries'

    options[:only_patterns] = [
      %r{[^/]+/all/}
    ]

    options[:container] = '.body-content'

    options[:attribution] = <<-HTML
      &copy; 2018 SaltStack. All Rights Reserved, SaltStack Inc.
    HTML
  end
end
