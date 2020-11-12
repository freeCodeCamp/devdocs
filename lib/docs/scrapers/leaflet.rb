module Docs
  class Leaflet < UrlScraper
    self.name = 'Leaflet'
    self.type = 'simple'
    self.slug = 'leaflet'
    self.links = {
      home: 'https://leafletjs.com/',
      code: 'https://github.com/Leaflet/Leaflet'
    }

    html_filters.push 'leaflet/entries', 'leaflet/clean_html', 'title'

    options[:container] = '.container'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2019 Vladimir Agafonkin<br>
      &copy; 2010&ndash;2011, CloudMade<br>
      Maps &copy; OpenStreetMap contributors.
    HTML

    version '1.7' do
      self.release = '1.7.1'
      self.base_url = "https://leafletjs.com/reference-#{release}.html"
    end

    version '1.6' do
      self.release = '1.6.0'
      self.base_url = "https://leafletjs.com/reference-#{release}.html"
    end

    version '1.5' do
      self.release = '1.5.1'
      self.base_url = "https://leafletjs.com/reference-1.5.0.html"
    end

    version '1.4' do
      self.release = '1.4.0'
      self.base_url = "https://leafletjs.com/reference-#{release}.html"
    end

    version '1.3' do
      self.release = '1.3.4'
      self.base_url = "https://leafletjs.com/reference-#{release}.html"
    end

    version '1.2' do
      self.release = '1.2.0'
      self.base_url = "https://leafletjs.com/reference-#{release}.html"
    end

    version '1.1' do
      self.release = '1.1.0'
      self.base_url = "https://leafletjs.com/reference-#{release}.html"
    end

    version '1.0' do
      self.release = '1.0.3'
      self.base_url = "https://leafletjs.com/reference-#{release}.html"
    end

    def get_latest_version(opts)
      doc = fetch_doc('https://leafletjs.com/index.html', opts)
      link = doc.css('ul > li > a').to_a.select {|node| node.content == 'Docs'}.first
      link['href'].scan(/reference-([0-9.]+)\.html/)[0][0]
    end
  end
end
