module Docs
  class Polars < UrlScraper
    self.name = 'Polars'
    self.type = 'sphinx'
    self.release = '1.41.0'
    self.base_url = 'https://docs.pola.rs/api/python/stable/reference/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://pola.rs/',
      code: 'https://github.com/pola-rs/polars'
    }

    html_filters.push 'polars/entries', 'sphinx/clean_html', 'polars/clean_html'

    # pydata-sphinx-theme keeps the page content in the article body.
    options[:container] = 'article.bd-article'

    options[:skip_patterns] = [/_changelog/, /whatsnew/]

    # https://github.com/pola-rs/polars/blob/main/LICENSE
    options[:attribution] = <<-HTML
      &copy; 2020 Ritchie Vink<br>
      &copy; 2022 Polars contributors<br>
      Licensed under the MIT License.
    HTML

    # Polars tags both Rust (rs-*) and Python (py-*) releases in the same repo.
    # The tags API only lists recent Rust ones, but the latest GitHub release is
    # always the Python one, so use that and drop the py- prefix.
    def get_latest_version(opts)
      get_latest_github_release('pola-rs', 'polars', opts).sub(/\Apy-/, '')
    end

    private

    def parse(response)
      if response.body.include?('class="sig')
        doc = Nokogiri::HTML5(response.body)
        doc.css('.sig').each do |node|
          node.css('.headerlink').remove
          node.css('.reference.external').each { |a| a.remove if a.text.strip == '[source]' }
          sig = node.text.gsub(/\s+/, ' ').strip
          if (m = sig.match(/\A(.+?\()\s*(.+?)\s*(\).*)\z/m))
            head, params, tail = m[1], m[2], m[3]
            split_params = params.split(/,\s+/).map { |p| p.sub(/,\z/, '') }.reject(&:empty?)
            sig = "#{head}\n    #{split_params.join(",\n    ")},\n#{tail}" unless split_params.empty?
          end
          pre = Nokogiri::XML::Node.new('pre', doc)
          pre['data-language'] = 'python'
          pre.content = sig
          node.replace(pre)
        end
        response.body.replace(doc.to_html)
      end
      super
    end
  end
end
