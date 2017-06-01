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

    options[:skip_patterns] = [/\Achanges/, /\A_modules/]

    options[:attribution] = <<-HTML
      &copy; 2016 Falcon Contributors<br>
      Licensed under the Apache 2 License.
    HTML

    version '1.2.0' do
      self.release = '1.2.0'
      self.base_url = "https://falcon.readthedocs.io/en/#{self.version}/"
    end

  end
end
