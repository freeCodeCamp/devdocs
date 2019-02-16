module Docs
  class Influxdata < UrlScraper
    self.name = 'InfluxData'
    self.type = 'simple'
    self.release = '1.3'
    self.base_url = 'https://docs.influxdata.com/'
    self.links = {
      home: 'https://www.influxdata.com/',
      code: 'https://github.com/influxdata/influxdb'
    }

    html_filters.push 'influxdata/entries', 'influxdata/clean_html', 'title'

    options[:trailing_slash] = true

    options[:root_title] = 'InfluxData Documentation'
    options[:title] = false

    options[:only_patterns] = [/(telegraf|influxdb|chronograf|kapacitor)\/v#{release}/]
    options[:skip_patterns] = [/enterprise/]

    options[:skip] = [
      "influxdb/v#{release}/sample_data/data_download/",
      "influxdb/v#{release}/tools/grafana/",
      "influxdb/v#{release}/about/",
      "influxdb/v#{release}/external_resources/",
      "influxdb/v#{release}/administration/security_best_practices/"
    ]

    options[:replace_paths] = {
      "telegraf/v#{release}/introduction/getting-started-telegraf/"  => "telegraf/v#{release}/introduction/getting_started/",
      "influxdb/v#{release}/write_protocols/line/"                   => "influxdb/v#{release}/write_protocols/line_protocol_tutorial/",
      "influxdb/v#{release}/write_protocols/graphite/"               => "influxdb/v#{release}/tools/graphite/",
      "influxdb/v#{release}/clients/api/"                            => "influxdb/v#{release}/tools/api_client_libraries/",
      "influxdb/v#{release}/concepts/010_vs_011/"                    => "influxdb/v#{release}/administration/differences/",
      "influxdb/v#{release}/write_protocols/write_syntax/"           => "influxdb/v#{release}/write_protocols/line_protocol_reference/",
      "influxdb/v#{release}/write_protocols/udp/"                    => "influxdb/v#{release}/tools/udp/"
    }

    options[:fix_urls] = ->(url) do
      url.sub! %r{/influxdb/v([\d\.]+)/.+/influxdb/v[\d\.]+/}, '/influxdb/v\1/'
      url
    end

    options[:attribution] = <<-HTML
      &copy; 2015 InfluxData, Inc.<br>
      Licensed under the MIT license.
    HTML
  end
end
