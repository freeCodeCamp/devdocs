module Docs
  class Cpp20 < UrlScraper
    self.name = 'C++20'
    self.slug = 'cpp20'
    self.type = 'c'
    self.base_url = 'https://en.cppreference.com/w/cpp/'
    self.root_path = 'header'

    html_filters.insert_before 'clean_html', 'c/fix_code'
    html_filters.push 'cpp20/entries', 'c/clean_html', 'title'

    options[:decode_and_clean_paths] = true
    options[:container] = '#content'
    options[:title] = false
    options[:root_title] = 'C++ Programming Language'

    options[:skip] = %w(
      language/extending_std.html
      language/history.html
      regex/ecmascript.html
      regex/regex_token_iterator/operator_cmp.html
    )

    options[:skip_patterns] = [/experimental/]

    options[:attribution] = <<-HTML
      &copy; cppreference.com<br>
      Licensed under the Creative Commons Attribution-ShareAlike Unported License v3.0.
    HTML

    # Same as get_latest_version in lib/docs/scrapers/c.rb
    def get_latest_version(opts)
      doc = fetch_doc('https://en.cppreference.com/w/Cppreference:Archives', opts)
      link = doc.at_css('a[title^="File:"]')
      date = link.content.scan(/(\d+)\./)[0][0]
      DateTime.strptime(date, '%Y%m%d').to_time.to_i
    end

  end
end
