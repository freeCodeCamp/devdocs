module Docs
  class Click < UrlScraper
    self.name = 'click'
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://click.palletsprojects.com/',
      code: 'https://github.com/pallets/click'
    }

    html_filters.push 'click/pre_clean_html', 'click/entries', 'sphinx/clean_html'

    options[:container] = '.body > section'
    options[:skip] = ['changes/', 'genindex/', 'py-modindex/']
    options[:title] = false

    options[:attribution] = <<-HTML
      &copy; Copyright 2014 Pallets.<br>
      Licensed under the BSD 3-Clause License.<br>
      We are not supported nor endorsed by Pallets.
    HTML

    self.release = '8.1.x'
    self.base_url = "https://click.palletsprojects.com/en/#{self.release}/"

    def get_latest_version(opts)
      get_latest_github_release('pallets', 'click', opts)
    end
  end
end
