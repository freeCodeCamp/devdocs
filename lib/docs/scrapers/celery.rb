module Docs
  class Celery < UrlScraper
    self.name = 'Celery'
    self.type = 'celery'
    self.release = '5.6.3'
    self.base_url = 'https://docs.celeryq.dev/en/stable/'
    self.links = {
      home: 'https://docs.celeryq.dev',
      code: 'https://github.com/celery/celery'
    }

    html_filters.push 'celery/entries', 'celery/clean_html'

    options[:container] = 'div.body'
    options[:rate_limit] = 100
    options[:only_patterns] = [/userguide\//, /reference\//]

    options[:attribution] = <<-HTML
      Copyright &copy; 2017-2026 Asif Saif Uddin, core team & contributors. All rights reserved.<br />
      Celery is licensed under The BSD License (3 Clause, also known as the new BSD license).  The license is an OSI approved Open Source license and is GPL-compatible.
    HTML

    def get_latest_version(opts)
      tags = get_github_tags('celery', 'celery', opts)
      tags[0]['name'][1..-1]
    end
  end
end
