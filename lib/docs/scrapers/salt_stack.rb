module Docs
  class SaltStack < UrlScraper
    self.type = 'simple'
    self.slug = 'saltstack'
    self.release = '3003'
    self.base_url = 'https://docs.saltproject.io/en/latest/'
    self.root_path = 'ref/index.html'
    self.links = {
      home: 'https://www.saltproject.io/',
      code: 'https://github.com/saltstack/salt'
    }

    html_filters.push 'salt_stack/clean_html', 'salt_stack/entries'

    options[:only_patterns] = [/all\//]
    options[:container] = '.body-content > .section'

    options[:attribution] = <<-HTML
      &copy; 2021 SaltStack.<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('saltstack', 'salt', opts)
    end
  end
end
