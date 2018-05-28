module Docs
  class Cpp < FileScraper
    self.name = 'C++'
    self.slug = 'cpp'
    self.type = 'c'
    self.dir = '/Users/Thibaut/DevDocs/Docs/cpp'
    self.base_url = 'http://en.cppreference.com/w/cpp/'
    self.root_path = 'header.html'

    html_filters.insert_before 'clean_html', 'c/fix_code'
    html_filters.push 'cpp/entries', 'c/clean_html', 'title'
    text_filters.push 'cpp/fix_urls'

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
    options[:only_patterns] = [/\.html\z/]

    options[:fix_urls] = ->(url) do
      url.sub! %r{\A.+/http%3A/}, 'http://'
      url.sub! 'http://en.cppreference.com/upload.cppreference.com', 'http://upload.cppreference.com'
      url
    end

    options[:attribution] = <<-HTML
      &copy; cppreference.com<br>
      Licensed under the Creative Commons Attribution-ShareAlike Unported License v3.0.
    HTML

    private

    def file_path_for(*)
      URI.unescape(super)
    end
  end
end
