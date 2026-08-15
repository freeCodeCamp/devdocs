module Docs
  class Cppref < UrlScraper
    self.abstract = true
    self.type = 'cppref'
    self.root_path = 'header'

    html_filters.insert_before 'clean_html', 'cppref/fix_code'
    html_filters.push  'cppref/clean_html', 'title'

    options[:decode_and_clean_paths] = true
    options[:container] = '#content'
    options[:title] = false
    options[:skip] = %w(language/history.html)

    options[:skip_patterns] = [
      /experimental/
    ]

    options[:attribution] = <<-HTML
      &copy; cppreference.com<br>
      Licensed under the Creative Commons Attribution-ShareAlike Unported License v3.0.
    HTML

    # Check if the 'headers' page has changed
    def get_latest_version(opts)
      title = self.base_url.path.delete_prefix('/w/') + self.root_path
      json = fetch_json("https://en.cppreference.com/w/api.php?action=query&prop=revisions&titles=#{title}&rvprop=timestamp&format=json", opts)
      timestamp = json['query']['pages'].values.first['revisions'][0]['timestamp']
      Date.iso8601(timestamp).to_time.to_i
    end

  end
end
