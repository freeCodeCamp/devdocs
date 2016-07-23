module Docs
  class Influxdata < UrlScraper
    self.name = 'InfluxData'
    self.type = 'influxdata'
    self.release = '0.13'
    self.base_url = 'https://docs.influxdata.com/'

    html_filters.push 'influxdata/entries', 'influxdata/clean_html', 'title'

    options[:trailing_slash] = true

    options[:root_title] = 'InfluxData Documentation'
    options[:title] = false

    options[:only_patterns] = [/(telegraf|influxdb|chronograf|kapacitor)\/v#{release}/]

    options[:skip] = [
      "influxdb/v#{release}/sample_data/data_download/",
      "influxdb/v#{release}/tools/grafana/",
      "influxdb/v#{release}/about/"
    ]

    options[:attribution] = <<-HTML
      &copy; 2015 InfluxData, Inc.<br>
      Licensed under the MIT license.
    HTML
  end
end
