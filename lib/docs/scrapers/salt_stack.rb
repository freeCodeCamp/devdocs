module Docs
  # The official documentation website is heavily rate-limited
  class SaltStack < FileScraper
    self.type = 'simple'
    self.slug = 'saltstack'
    self.release = '2019.2.0'
    self.base_url = 'https://docs.saltstack.com/en/latest/'
    self.root_path = 'ref/index.html'
    self.links = {
      home: 'https://www.saltstack.com/',
      code: 'https://github.com/saltstack/salt'
    }

    html_filters.push 'salt_stack/clean_html', 'salt_stack/entries'

    options[:only_patterns] = [/all\//]
    options[:container] = '.body-content > .section'

    options[:attribution] = <<-HTML
      &copy; 2019 SaltStack.<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('saltstack', 'salt', opts)
    end
  end
end
