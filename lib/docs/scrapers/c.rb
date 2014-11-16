module Docs
  class C < FileScraper
    self.type = 'c'
    self.dir = '/Users/Thibaut/DevDocs/Docs/C/en/c'
    self.base_url = 'http://en.cppreference.com/w/c/'
    self.root_path = 'header.html'

    html_filters.insert_before 'clean_html', 'c/fix_code'
    html_filters.push 'c/entries', 'c/clean_html', 'title'
    text_filters.push 'c/fix_urls'

    options[:container] = '#content'
    options[:title] = false
    options[:root_title] = 'C Programming Language'
    options[:skip] = %w(language/history.html)

    options[:fix_urls] = ->(url) do
      url.sub! %r{\A.+/http%3A/}, "http://"
      url
    end

    options[:attribution] = <<-HTML
      &copy; cppreference.com<br>
      Licensed under the Creative Commons Attribution-ShareAlike Unported License v3.0.
    HTML
  end
end
