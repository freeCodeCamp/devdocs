module Docs
  class Kotlin < UrlScraper
    self.type = 'kotlin'
    self.release = '1.2.21'
    self.base_url = 'https://kotlinlang.org/'
    self.root_path = 'api/latest/jvm/stdlib/index.html'
    self.links = {
      home: 'https://kotlinlang.org/',
      code: 'https://github.com/JetBrains/kotlin'
    }

    html_filters.push 'kotlin/entries', 'kotlin/clean_html'

    options[:container] = '.global-content'

    options[:only_patterns] = [/\Adocs\/tutorials\//, /\Adocs\/reference\//, /\Aapi\/latest\/jvm\/stdlib\//]
    options[:skip_patterns] = [/stdlib\/org\./]
    options[:skip] = %w(
      api/latest/jvm/stdlib/alltypes/index.html
      docs/
      docs/videos.html
      docs/events.html
      docs/resources.html
      docs/reference/grammar.html)
    options[:replace_paths] = { 'api/latest/jvm/stdlib/' => 'api/latest/jvm/stdlib/index.html' }

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2018 JetBrains s.r.o.<br>
      Licensed under the Apache License, Version 2.0.
    HTML
  end
end
