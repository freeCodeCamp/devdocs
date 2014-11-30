module Docs
  class Phpunit < UrlScraper
    self.name = 'PHPUnit'
    self.type = 'phpunit'
    self.slug = 'phpunit'
    self.version = '4.3'
    self.base_url = 'https://phpunit.de/manual/4.3/en/'
    self.initial_paths = %w(appendixes.assertions.html appendixes.annotations.html)

    html_filters.push 'phpunit/entries', 'phpunit/clean_html', 'title'

    options[:skip_links] = true

    options[:title] = false
    options[:root_title] = "#{self.name} #{self.version}"

    options[:fix_urls] = ->(url) do
      if self.initial_paths.include? url[/\/([A-z.-]+)#/, 1]
        url = url[/#(.+)/, 1].downcase
        url.gsub! /(\w+\.\w+)\.(\w+)/, '\1#\2'
      end
      url
    end


    options[:attribution] = <<-HTML
      &copy; 2005&ndash;2014 Sebastian Bergmann<br>
      Licensed under the Creative Commons Attribution 3.0 Unported License.
    HTML
  end
end
