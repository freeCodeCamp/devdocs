module Docs
  class Rdoc < FileScraper
    self.abstract = true
    self.type = 'rdoc'
    self.root_path = 'table_of_contents.html'

    html_filters.replace 'container', 'rdoc/container'
    html_filters.push 'rdoc/entries', 'rdoc/clean_html', 'title'

    options[:title] = false
    options[:skip] = %w(index.html)
    options[:skip_patterns] = [
      /history/i,
      /rakefile/i,
      /changelog/i,
      /readme/i,
      /news/i,
      /license/i]
  end
end
