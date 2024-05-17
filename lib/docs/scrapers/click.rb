module Docs
  class Click < UrlScraper
    self.name = 'click'
    self.type = 'sphinx'  #'simple'
    self.release = '8.1.7'
    self.base_url = 'https://click.palletsprojects.com/en/8.1.x/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://click.palletsprojects.com/',
      code: 'https://github.com/pallets/click'
    }

    html_filters.push 'click/pre_clean_html', 'click/entries', 'click/clean_html', 'sphinx/clean_html', 'title'

    options[:skip] = ['changes/', 'genindex/', 'py-modindex/', 'license/']
    options[:container] = '.body > section'
    options[:title] = false

    options[:attribution] = <<-HTML
      &copy; Copyright 2014 Pallets.<br>
      Licensed under the BSD 3-Clause License.<br>
      We are not supported nor endorsed by Pallets.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('pallets', 'click', opts)
    end
  end
end
