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
      doc = fetch_doc((self.base_url + self.root_path).to_s, opts)
      date = doc.at_css('#footer-info-lastmod').content
      date = date.match(/[[:digit:]]{1,2} .* [[:digit:]]{4}/).to_s
      date = DateTime.strptime(date, '%e %B %Y').to_time.to_i
    end

  end
end
