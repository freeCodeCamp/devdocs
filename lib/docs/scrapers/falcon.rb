module Docs
  class Falcon < UrlScraper
    self.type = 'sphinx'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://falconframework.org/',
      code: 'https://github.com/falconry/falcon'
    }

    html_filters.push 'falcon/entries', 'sphinx/clean_html'

    options[:container] = '.body'

    options[:skip] = %w(user/index.html api/index.html deploy/index.html)
    options[:skip_patterns] = [/\Achanges/, /\A_modules/, /\Acommunity/]

    options[:attribution] = <<-HTML
      &copy; 2019 by Falcon contributors<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    version '2.0' do
      self.release = '2.0.0'
      self.base_url = "https://falcon.readthedocs.io/en/#{self.release}/"
    end

    version '1.4' do
      self.release = '1.4.1'
      self.base_url = "https://falcon.readthedocs.io/en/#{self.release}/"
    end

    version '1.3' do
      self.release = '1.3.0'
      self.base_url = "https://falcon.readthedocs.io/en/#{self.release}/"
    end

    version '1.2' do
      self.release = '1.2.0'
      self.base_url = "https://falcon.readthedocs.io/en/#{self.release}/"
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://falcon.readthedocs.io/en/stable/changes/index.html', opts)
      doc.at_css('#changelogs ul > li > a').content
    end
  end
end
