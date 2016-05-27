module Docs
  class Kotlin < UrlScraper
    self.type = 'kotlin'
    self.release = '1.0.2'
    self.base_url = 'https://kotlinlang.org/api/latest/jvm/stdlib/'
    self.root_path = 'index.html'
    self.links = {
      home: 'https://kotlinlang.org/',
      code: 'https://github.com/JetBrains/kotlin'
    }

    html_filters.push 'kotlin/entries', 'kotlin/clean_html'

    options[:container] = '.page-content'

    options[:attribution] = <<-HTML
      &copy; 2016 JetBrains<br>
      Licensed under the Apache License, Version 2.0.
    HTML
  end
end
