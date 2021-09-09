module Docs
  class Cppref < UrlScraper
    self.abstract = true
    self.type = 'cppref'
    self.root_path = 'header'

    html_filters.insert_before 'clean_html', 'cppref/fix_code'
    html_filters.push  'cppref/clean_html', 'title'
      # 'cpp20/entries',
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

    # def get_latest_version

    # end

  end
end
