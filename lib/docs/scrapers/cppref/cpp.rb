module Docs
  class Cpp < Cppref
    self.name = 'C++'
    self.slug = 'cpp'
    self.base_url = 'https://en.cppreference.com/w/cpp/'
    # release = '2023-03-24'

    html_filters.insert_before 'cppref/clean_html', 'cpp/entries'

    options[:root_title] = 'C++ Programming Language'

    options[:skip] = %w(
      language/extending_std.html
      language/history.html
      regex/ecmascript.html
      regex/regex_token_iterator/operator_cmp.html
    )

  end
end
