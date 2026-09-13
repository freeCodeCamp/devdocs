module Docs
  class Tokio < UrlScraper
    self.name = 'Tokio'
    self.type = 'tokio'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://tokio.rs/',
      code: 'https://github.com/tokio-rs/tokio'
    }

    html_filters.push 'tokio/entries', 'tokio/clean_html'

    options[:rate_limit] = 50
    options[:container] = 'section.content'
    options[:skip_patterns] = [/\/next|\/\d\.\d*/, /rabbitmq\//]
    options[:attribution] = <<-HTML
      MIT License<br />
      Copyright &copy; Tokio Contributors
    HTML

    version do
      self.release = '1.53.1'
      self.base_url = "https://docs.rs/tokio/#{self.release}/tokio/"
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://docs.rs/tokio/latest/tokio/index.html', opts)
      doc.at_css('h2 > .version').content.strip
    end
  end
end
