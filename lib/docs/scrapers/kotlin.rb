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
      &copy; 2010&ndash;2026 JetBrains s.r.o. and Kotlin Programming Language contributors<br>
      Licensed under the Apache License, Version 2.0.
    HTML

    version '2' do
      self.release = '2.4.20'
      self.root_path = 'api/core/index.html'
      self.initial_paths = %w(docs/getting-started.html)

      html_filters.replace 'kotlin/entries', 'kotlin/entries_v2'
      html_filters.replace 'kotlin/clean_html', 'kotlin/clean_html_v2'

      # The guides are rendered by Writerside into <article>, the API reference by Dokka 2
      # into .main-content. Neither includes the site-wide navigation, so the guides are
      # crawled through their "previous/next" links and the API reference through its indexes.
      options[:container] = ->(filter) { filter.subpath.start_with?('api/') ? '.main-content' : 'article' }
      options[:only_patterns] = [/\Adocs\//, /\Aapi\/core\//]
      # api/core/<version>/ holds the API reference of superseded releases.
      options[:skip_patterns] = [%r{\Aapi/core/\d}, %r{\Aapi/core/[^/]+/org\.}, /navigation\.html\z/]
      options[:skip] = %w(
        docs/home.html
        docs/events.html
        docs/resources.html)
    end

    version '1.9' do
      self.release = '1.9.0'
      self.headers = { 'User-Agent' => 'devdocs.io' , 'Cookie' => 'x-ab-test-spring-boot-learning-path=0; userToken=r33dgpe8x3q5vswekg16a'  }
    end

    version '1.8' do
      self.release = '1.8.0'
      self.headers = { 'User-Agent' => 'devdocs.io' , 'Cookie' => 'x-ab-test-spring-boot-learning-path=0; userToken=r33dgpe8x3q5vswekg16a'  }
    end

    version '1.7' do
      self.release = '1.7.20'
    end

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
      return false if response.body =~ /http-equiv="refresh"/i
      # Landing pages such as docs/home.html are rendered client-side and hold no content.
      response.body !~ /data-template="section-page"/
    end

    def parse(response)
      response.body.gsub! %r{<div\ class="code-block" data-lang="([^"]+)"[^>]*>([\W\w]+?)</div>}, '<pre class="code" data-language="\1">\2</pre>'
      super
    end
  end
end
