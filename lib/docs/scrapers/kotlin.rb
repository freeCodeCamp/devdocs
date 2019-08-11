module Docs
  class Kotlin < UrlScraper
    self.type = 'kotlin'
    self.release = '1.3.41'
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
    options[:replace_paths] = {
      'api/latest/jvm/stdlib/' => 'api/latest/jvm/stdlib/index.html',
      'docs/reference/coroutines.html' => 'docs/reference/coroutines-overview.html',
      'api/latest/jvm/stdlib/kotlin/fold.html' => 'api/latest/jvm/stdlib/kotlin.collections/fold.html',
      'api/latest/jvm/stdlib/kotlin/get-or-else.html' => 'api/latest/jvm/stdlib/kotlin.collections/get-or-else.html',
      'api/latest/jvm/stdlib/kotlin/map.html' => 'api/latest/jvm/stdlib/kotlin.collections/map.html',
      'docs/tutorials/native/targeting-multiple-platforms.html' => 'docs/tutorials/native/basic-kotlin-native-app.html',
      'api/latest/jvm/stdlib/kotlin/-throwable/print-stack-trace.html' => 'api/latest/jvm/stdlib/kotlin/print-stack-trace.html',
    }

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2019 JetBrains s.r.o.<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    def get_latest_version(opts)
      get_latest_github_release('JetBrains', 'kotlin', opts)
    end
  end
end
