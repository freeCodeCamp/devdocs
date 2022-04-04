module Docs
  class Kotlin < UrlScraper
    self.type = 'kotlin'
    self.base_url = 'https://kotlinlang.org/'
    self.root_path = 'api/latest/jvm/stdlib/index.html'
    self.links = {
      home: 'https://kotlinlang.org/',
      code: 'https://github.com/JetBrains/kotlin'
    }

    html_filters.push 'kotlin/entries', 'kotlin/clean_html'

    options[:container] = 'article'
    options[:only_patterns] = [/\Adocs\//, /\Aapi\/latest\/jvm\/stdlib\//]
    options[:skip_patterns] = [/stdlib\/org\./]
    options[:skip] = %w(
      api/latest/jvm/stdlib/alltypes/index.html
      docs/
      docs/videos.html
      docs/events.html
      docs/resources.html
      docs/reference/grammar.html)

    options[:fix_urls] = ->(url) do
      url.sub! %r{/docs/reference/}, '/docs/'
      url
    end

    options[:attribution] = <<-HTML
      &copy; 2010&ndash;2022 JetBrains s.r.o. and Kotlin Programming Language contributors<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    version '1.6' do
      self.release = '1.6.20'
    end

    version '1.4' do
      self.release = '1.4.10'
    end

    def get_latest_version(opts)
      get_latest_github_release('JetBrains', 'kotlin', opts)
    end

    private

    def process_response?(response)
      return false unless super
      response.body !~ /http-equiv="refresh"/i
    end
  end
end
