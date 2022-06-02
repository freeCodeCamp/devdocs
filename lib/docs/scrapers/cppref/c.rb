module Docs
  class C < Cppref
    self.name = 'c'
    self.slug = 'c'
    self.base_url = 'https://en.cppreference.com/w/c/'

    html_filters.insert_before 'cppref/clean_html', 'c/entries'

    options[:root_title] = 'C Programming Language'

  end
end
