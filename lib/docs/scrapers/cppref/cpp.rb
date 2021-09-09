module Docs
  class Cpp < Cppref
    self.name = 'C++'
    self.slug = 'cpp'
    self.type = 'c'
    self.base_url = 'https://en.cppreference.com/w/cpp/'

    html_filters.insert_before 'cppref/clean_html', 'cpp/entries'

    options[:root_title] = 'C++ Programming Language'

    options[:skip] = %w(
      language/extending_std.html
      language/history.html
      regex/ecmascript.html
      regex/regex_token_iterator/operator_cmp.html
    )

    # Same as get_latest_version in lib/docs/scrapers/c.rb
    def get_latest_version(opts)
      doc = fetch_doc('https://en.cppreference.com/w/Cppreference:Archives', opts)
      link = doc.at_css('a[title^="File:"]')
      date = link.content.scan(/(\d+)\./)[0][0]
      DateTime.strptime(date, '%Y%m%d').to_time.to_i
    end

  end
end
