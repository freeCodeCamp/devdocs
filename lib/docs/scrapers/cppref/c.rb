module Docs
  class C < Cppref
    self.name = 'C'
    self.slug = 'c'
    self.base_url = 'https://en.cppreference.com/c/'
    # release = '2025-02-09'

    html_filters.insert_before 'cppref/clean_html', 'c/entries'

    options[:root_title] = 'C Programming Language'

  end
end
