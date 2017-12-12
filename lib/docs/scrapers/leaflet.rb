module Docs
  class Leaflet < UrlScraper
    self.name = 'Leaflet'
    self.type = 'leaflet'
    self.slug = 'leaflet'
    self.links = {
      home: 'http://leafletjs.com/',
      code: 'https://github.com/Leaflet/Leaflet'
    }

    html_filters.push 'leaflet/entries', 'leaflet/clean_html', 'title'

    options[:container] = '.container'
    options[:skip_links] = true

    options[:attribution] = <<-HTML
      &copy; 2017 <a href="http://agafonkin.com/en">Vladimir Agafonkin</a>.
      Maps &copy; <a href="http://openstreetmap.org/copyright">OpenStreetMap</a> contributors.</p>
    HTML

    version '1.2' do
      self.release = '1.2.0'
      self.base_url = "http://leafletjs.com/reference-#{release}.html"
    end

    version '1.1' do
      self.release = '1.1.0'
      self.base_url = "http://leafletjs.com/reference-#{release}.html"
    end

    version '1.0' do
      self.release = '1.0.3'
      self.base_url = "http://leafletjs.com/reference-#{release}.html"
    end

  end
end
