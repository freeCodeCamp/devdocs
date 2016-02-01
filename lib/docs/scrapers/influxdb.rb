module Docs
  class Influxdb < UrlScraper
    self.name = 'InfluxDB'
    self.type = 'influxdb'
    self.release = '0.9'
    self.base_url = 'https://docs.influxdata.com/influxdb/v0.9/'
    
    html_filters.push 'influxdb/entries', 'influxdb/clean_html'

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2015 InfluxData<br>
      Licensed under the MIT license.
    HTML
  end
end
